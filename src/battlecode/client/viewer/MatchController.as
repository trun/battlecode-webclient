package battlecode.client.viewer {

    import battlecode.client.viewer.render.DrawRobot;
    import battlecode.client.viewer.render.DrawState;
    import battlecode.events.MatchEvent;
    import battlecode.serial.Match;

    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.EventDispatcher;

    import mx.core.Application;
    import mx.events.PropertyChangeEvent;

    [Event(name="matchChange", type="battlecode.events.MatchEvent")]
    [Event(name="roundChange", type="battlecode.events.MatchEvent")]
    public class MatchController extends EventDispatcher {
        private const NORAML_FRAMERATE:int = 15;
        private const FAST_FRAMERATE:int = 30;

        private var stage:Stage;
        private var rollingFramerates:Array;
        private var lastRoundTime:Number;
        [Bindable]
        private var _fps:uint = 0;
        [Bindable]
        private var _keyframeRate:uint = 0;

        [Bindable]
        private var _prevEnabled:Boolean = false;
        [Bindable]
        private var _nextEnabled:Boolean = false;
        [Bindable]
        private var _currentRound:uint = 0;

        [Bindable]
        private var _playing:Boolean = false;
        [Bindable]
        private var _fastForwarding:Boolean = false;

        [Bindable]
        private var _match:Match;
        [Bindable]
        private var _currentMatch:uint;
        private var matches:Vector.<Match>;

        [Bindable]
        private var _currentState:DrawState;
        private var keyframes:Vector.<DrawState>;

        [Bindable]
        private var _selectedRobot:DrawRobot;

        public function MatchController() {
            Application.application.addEventListener("applicationComplete", onApplicationComplete);
            this.rollingFramerates = new Array();
        }

        private function onApplicationComplete(e:Event):void {
            stage = Application.application.stage;
            stage.frameRate = (fastForwarding) ? FAST_FRAMERATE : NORAML_FRAMERATE;
            stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        [Bindable(event="propertyChange")]
        public function get prevEnabled():Boolean {
            return _prevEnabled;
        }

        public function set prevEnabled(value:Boolean):void {
            _prevEnabled = value;
            dispatchEvent(new Event(PropertyChangeEvent.PROPERTY_CHANGE));
        }

        [Bindable(event="propertyChange")]
        public function get nextEnabled():Boolean {
            return _nextEnabled;
        }

        public function set nextEnabled(value:Boolean):void {
            _nextEnabled = value;
            dispatchEvent(new Event(PropertyChangeEvent.PROPERTY_CHANGE));
        }

        [Bindable(event="propertyChange")]
        public function get currentRound():uint {
            return _currentRound;
        }

        public function set currentRound(value:uint):void {
            value = Math.min(Math.max(0, value), match.getRounds()); // clamp

            // keyframing
            if (value == currentRound + 1) {
                currentState.applyDelta(match.getRoundDelta(currentRound));
                currentState.applyStats(match.getRoundStats(currentRound));
                if (value % keyframeRate == 0 && keyframes[uint(value / keyframeRate)] == null) {
                    keyframes[uint(value / keyframeRate)] = currentState.clone();
                }
            } else {
                var keyframe:uint = uint(value / keyframeRate);
                while (keyframes[keyframe] == null) {
                    keyframe--;
                }
                var round:uint = keyframe * keyframeRate;
                // if current round is closer use that as keyframe
                if (value > currentRound && currentRound > round) {
                    round = currentRound;
                } else {
                    _currentState = keyframes[keyframe].clone();
                }
                while (round < value) {
                    currentState.applyDelta(match.getRoundDelta(round));
                    currentState.applyStats(match.getRoundStats(round));
                    round++;
                    if (round % keyframeRate == 0 && keyframes[uint(round / keyframeRate)] == null) {
                        keyframes[uint(round / keyframeRate)] = currentState.clone();
                    }
                }
            }

            var currentRoundTime:Number = (new Date()).getTime();
            var framerate:uint = 1 / ((currentRoundTime - lastRoundTime) / 1000);
            lastRoundTime = currentRoundTime;

            var limit:uint = (playing) ? 10 : 1;
            rollingFramerates.push(framerate);
            while (rollingFramerates.length > limit)
                rollingFramerates.shift();
            var total:Number = 0;
            for (var i:uint = 0; i < rollingFramerates.length; i++) {
                total += rollingFramerates[i];
            }
            _fps = Math.ceil(total / rollingFramerates.length);

            // update
            _currentRound = value;
            dispatchEvent(new Event(PropertyChangeEvent.PROPERTY_CHANGE));
            dispatchEvent(new MatchEvent(MatchEvent.ROUND_CHANGE, false, false, currentRound, currentMatch));
        }

        [Bindable(event="propertyChange")]
        public function get fps():uint {
            return _fps;
        }

        [Bindable(event="propertyChange")]
        public function get playing():Boolean {
            return _playing;
        }

        public function set playing(value:Boolean):void {
            _playing = value;
            rollingFramerates = new Array(); // clear saved framerates
            dispatchEvent(new Event(PropertyChangeEvent.PROPERTY_CHANGE));
        }

        [Bindable(event="propertyChange")]
        public function get fastForwarding():Boolean {
            return _fastForwarding;
        }

        public function set fastForwarding(value:Boolean):void {
            _fastForwarding = value;
            dispatchEvent(new Event(PropertyChangeEvent.PROPERTY_CHANGE));

            // update delay to reflect fast forward
            stage.frameRate = (value) ? FAST_FRAMERATE : NORAML_FRAMERATE;
        }

        [Bindable(event="propertyChange")]
        public function get currentState():DrawState {
            return _currentState;
        }

        [Bindable(event="propertyChange")]
        public function get match():Match {
            return _match;
        }

        [Bindable(event="propertyChange")]
        public function get totalMatches():uint {
            return matches.length;
        }

        [Bindable(event="propertyChange")]
        public function get currentMatch():uint {
            return _currentMatch;
        }

        public function set currentMatch(value:uint):void {
            if (value < matches.length) {
                _currentMatch = value;
                _currentRound = 0;
                _match = matches[value];
                _currentState = new DrawState(match.getMap());
                _prevEnabled = value > 0;
                _nextEnabled = value < matches.length - 1;
                keyframes = new Vector.<DrawState>(uint(match.getRounds() / 50) + 1, true);
                keyframes[0] = currentState.clone();
                dispatchEvent(new Event(PropertyChangeEvent.PROPERTY_CHANGE));
                dispatchEvent(new MatchEvent(MatchEvent.MATCH_CHANGE, false, false, currentRound, currentMatch));
            }
        }

        [Bindable(event="propertyChange")]
        public function get keyframeRate():uint {
            return _keyframeRate;
        }

        public function set keyframeRate(value:uint):void {
            _keyframeRate = value;
            dispatchEvent(new Event(PropertyChangeEvent.PROPERTY_CHANGE));
        }

        [Bindable(event="propertyChange")]
        public function get selectedRobot():DrawRobot {
            return _selectedRobot;
        }

        public function set selectedRobot(value:DrawRobot):void {
            _selectedRobot = value;
            dispatchEvent(new Event(PropertyChangeEvent.PROPERTY_CHANGE));
        }

        public function setMatches(matches:Vector.<Match>):void {
            if (matches != null && matches.length > 0) {
                this.matches = matches;
                this.currentMatch = 0;
            }
        }

        public function getMatches():Vector.<Match> {
            return matches;
        }

        private function onEnterFrame(e:Event):void {
            if (playing) {
                currentRound = Math.min(currentRound + 1, match.getRounds());
                if (currentRound == match.getRounds())
                    playing = false;
            }
        }

    }

}