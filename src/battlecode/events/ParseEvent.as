package battlecode.events {
    import flash.events.Event;

    public class ParseEvent extends Event {
        public static const PROGRESS:String = "parseProgress";
        public static const COMPLETE:String = "parseComplete";

        public var rowsParsed:uint;
        public var rowsTotal:uint;
        public var matchesParsed:uint;
        public var matchesTotal:uint;

        public function ParseEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, rowsParsed:uint = 0, rowsTotal:uint = 0, matchesParsed:uint = 0, matchesTotal:uint = 0) {
            super(type, bubbles, cancelable);
            this.rowsParsed = rowsParsed;
            this.rowsTotal = rowsTotal;
            this.matchesParsed = matchesParsed;
            this.matchesTotal = matchesTotal;
        }

        public override function clone():Event {
            return new ParseEvent(type, bubbles, cancelable, rowsParsed, rowsTotal, matchesParsed, matchesTotal);
        }

        public override function toString():String {
            return formatToString("MatchEvent", "type", "bubbles", "cancelable", "eventPhase");
        }

    }

}