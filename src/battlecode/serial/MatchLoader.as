package battlecode.serial {
    import battlecode.events.ParseEvent;
    import battlecode.util.GZIP;

    import flash.errors.MemoryError;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.TimerEvent;
    import flash.net.URLRequest;
    import flash.net.URLStream;
    import flash.system.System;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    import mx.controls.Alert;

    [Event(name="parseProgress", type="battlecode.events.ParseEvent")]
    [Event(name="parseComplete", type="battlecode.events.ParseEvent")]
    [Event(name="progress", type="flash.events.ProgressEvent")]
    [Event(name="complete", type="flash.events.Event")]
    public class MatchLoader extends EventDispatcher {
        private var matchPath:String;
        private var stream:URLStream;
        private var matches:Vector.<Match>;
        private var numMatches:uint = 0;
        private var builder:MatchBuilder;

        private var gamesXML:XMLList;
        private var currentIndex:uint = 0;
        private var gameTimer:Timer;

        public function MatchLoader() {
            this.stream = new URLStream();
            this.stream.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress, false, 0, true);
            this.stream.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
            this.stream.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
            this.stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
        }

        public function load(file:String):void {
            matchPath = file;
            this.stream.load(new URLRequest(file));
        }

        public function loadData(matchBytes:ByteArray):void {
            // decompress the bytes (they are GZIP'd)
            try {
                matchBytes = GZIP.decompress(matchBytes);
            } catch (e:Error) {
            }

            trace("--- DECOMPRESSION ---");
            trace("MEM USAGE: " + Math.round(System.totalMemory / 1024 / 1024) + "MB");

            try {
                // parse the xml from the decompressed byte stream
                var xmlStr:String = matchBytes.readUTFBytes(matchBytes.bytesAvailable);
                var xml:XML = new XML(xmlStr);
            } catch (e:MemoryError) {
                Alert.show("Memory allocation error: " + e.message);
                return;
            } catch (e:TypeError) {
                trace("TypeError: " + e.message);
                Alert.show("Unauthorized: " + e.message);
                return;
            }

            // clear match bytes
            matchBytes.clear();

            // generate new matches
            numMatches = parseInt(xml.child("ser.MatchHeader").length());
            matches = new Vector.<Match>();

            gamesXML = xml.children();

            gameTimer = new Timer(30);
            gameTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
            gameTimer.start();

            trace("--- XML PARSE ---");
            trace("MEM USAGE: " + Math.round(System.totalMemory / 1000 / 1000) + "MB");

            dispatchEvent(new Event(Event.COMPLETE));
        }

        public function getMatches():Vector.<Match> {
            return matches;
        }

        public function getNumMatches():uint {
            return numMatches;
        }

        private function onDownloadProgress(e:ProgressEvent):void {
            dispatchEvent(e);
        }

        private function onComplete(e:Event):void {
            var matchBytes:ByteArray = new ByteArray();
            stream.readBytes(matchBytes);
            stream.close();
            stream = null;

            loadData(matchBytes);
        }

        private function onIOError(e:IOErrorEvent):void {
            trace("match load failed: " + e.toString());
            Alert.show("Could not load the specified match file: File " + matchPath + " not found");
        }

        private function onSecurityError(e:SecurityError):void {
            trace("match load failed: " + e.toString());
            Alert.show("Could not load the specified match file: Security error");
        }

        private function onTimerTick(e:TimerEvent):void {
            var start:Number = getTimer();
            while(getTimer() - start < 30 && currentIndex < gamesXML.length()) {
                var node:XML = gamesXML[currentIndex++];
                var nodeName:String = node.name().toString();
                switch (nodeName) {
                    case "ser.MatchHeader":
                        builder = new MatchBuilder();
                        builder.setHeader(node);
                        break;
                    case "ser.MatchFooter":
                        builder.setFooter(node);
                        matches.push(builder.build());
                        builder = null;
                        trace("--- MATCH "+matches.length+" ---");
                        trace("MEM USAGE: " + Math.round(System.totalMemory / 1024 / 1024) + "MB");
                        break;
                    case "ser.ExtensibleMetadata":
                        builder.setExtensibleMetadata(node);
                        break;
                    case "ser.GameStats":
                        builder.setGameStats(node);
                        break;
                    case "ser.RoundDelta":
                        builder.addRoundDelta(node);
                        break;
                    case "ser.RoundStats":
                        builder.addRoundStats(node);
                        break;
                    default:
                        trace("Unknown node: " + node.name());
                        break;
                }
            }

            var progressEvent:ParseEvent;
            if (matches.length == numMatches) {
                progressEvent = new ParseEvent(ParseEvent.COMPLETE);
                gameTimer.stop();
            } else {
                progressEvent = new ParseEvent(ParseEvent.PROGRESS);
            }
            progressEvent.rowsParsed = currentIndex;
            progressEvent.rowsTotal = gamesXML.length();
            progressEvent.matchesParsed = matches.length;
            progressEvent.matchesTotal = numMatches;
            dispatchEvent(progressEvent);
        }
    }
}