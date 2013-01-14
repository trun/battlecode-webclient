package battlecode.events {
    import flash.events.Event;

    public class MatchEvent extends Event {
        public static const ROUND_CHANGE:String = "roundChange";
        public static const MATCH_CHANGE:String = "matchChange";

        public var currentRound:uint;
        public var currentMatch:uint;

        public function MatchEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, currentRound:uint = 0, currentMatch:uint = 0) {
            super(type, bubbles, cancelable);
            this.currentRound = currentRound;
            this.currentMatch = currentMatch;
        }

        public override function clone():Event {
            return new MatchEvent(type, bubbles, cancelable, currentRound, currentMatch);
        }

        public override function toString():String {
            return formatToString("MatchEvent", "type", "bubbles", "cancelable", "eventPhase");
        }

    }

}