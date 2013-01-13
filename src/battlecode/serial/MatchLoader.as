package battlecode.serial {
	
	import battlecode.events.MatchLoadProgressEvent;
	import battlecode.util.GZIP;
	import flash.errors.MemoryError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLStream;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import mx.controls.Alert;
	
	[Event(name="matchParseProgress", type="battlecode.events.MatchLoadProgressEvent")]
	[Event(name="matchParseComplete", type="battlecode.events.MatchLoadProgressEvent")]
	[Event(name="gameParseProgress", type="battlecode.events.MatchLoadProgressEvent")]
	[Event(name="gameParseComplete", type="battlecode.events.MatchLoadProgressEvent")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="complete", type="flash.events.Event")]
	public class MatchLoader extends EventDispatcher {
		private var matchPath:String;
		private var stream:URLStream;
		private var matches:Vector.<Match>;
		private var numMatches:uint = 0;

		private var gamesXML:XMLList;
		private var currentGame:uint = 0;
		private var gameTimer:Timer;
		private var nextMatchReady:Boolean = true;
		
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
			// read raw bytes into a new ByteArray
			var matchBytes:ByteArray = new ByteArray();
			stream.readBytes(matchBytes);
			stream.close();
			stream = null;
			
			// decompress the bytes (they are GZIP'd)
			try {
				matchBytes = GZIP.decompress(matchBytes);
			} catch (e:Error) { }
			
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
			numMatches = parseInt(xml.child("ser.MatchHeader").attribute("matchCount"));
            matches = new Vector.<Match>();

            gamesXML = xml.children();
            var builder:MatchBuilder;
            for each (var node:XML in gamesXML) {
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

			//gameTimer = new Timer(200);
			//gameTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
			//gameTimer.start();
			
			//var progressEvent:MatchLoadProgressEvent = new MatchLoadProgressEvent(MatchLoadProgressEvent.MATCH_PARSE_PROGRESS);
			//progressEvent.itemsComplete = currentGame;
			//progressEvent.itemsTotal = numMatches;
			//dispatchEvent(progressEvent);

			trace("--- XML PARSE ---");
			trace("MEM USAGE: " + Math.round(System.totalMemory / 1000 / 1000) + "MB");

            dispatchEvent(e);

            var completeEvent:MatchLoadProgressEvent = new MatchLoadProgressEvent(MatchLoadProgressEvent.MATCH_PARSE_COMPLETE);
            completeEvent.itemsTotal = numMatches;
            completeEvent.itemsComplete = numMatches;
            dispatchEvent(completeEvent);
		}
		
		private function onIOError(e:IOErrorEvent):void {
			trace("match load failed: " + e.toString());
			Alert.show("Could not load the specified match file: File " + matchPath + " not found");
		}
		
		private function onSecurityError(e:SecurityError):void {
			trace("match load failed: " + e.toString());
			Alert.show("Could not load the specified match file: Security error");
		}

        /*
		private function onTimerTick(e:TimerEvent):void {
			if (!nextMatchReady) return;

			var match:Match = new Match();
			match.addEventListener(MatchLoadProgressEvent.GAME_PARSE_PROGRESS, onGameParseProgress);
			match.addEventListener(MatchLoadProgressEvent.GAME_PARSE_COMPLETE, onGameParseComplete);
			match.parseMatch(gamesXML[currentGame++]);
			matches.push(match);
			
			var progressEvent:MatchLoadProgressEvent = new MatchLoadProgressEvent(MatchLoadProgressEvent.MATCH_PARSE_PROGRESS);
			progressEvent.itemsComplete = currentGame;
			progressEvent.itemsTotal = numMatches;
			dispatchEvent(progressEvent);
			
			nextMatchReady = false;
		}
		
		private function onGameParseProgress(e:MatchLoadProgressEvent):void {
			dispatchEvent(e);
		}
		
		private function onGameParseComplete(e:MatchLoadProgressEvent):void {
			nextMatchReady = true;
			
			if (currentGame == numMatches) {
				dispatchEvent(new MatchLoadProgressEvent(MatchLoadProgressEvent.MATCH_PARSE_COMPLETE));
				gameTimer.stop();
			}
			
			trace("--- MATCH "+currentGame+" ---");
			trace("MEM USAGE: " + Math.round(System.totalMemory / 1024 / 1024) + "MB");
			
			dispatchEvent(e);
		}
		*/
		
	}
}