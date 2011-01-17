package battlecode.events 
{
	import flash.events.Event;
	
	public class MatchLoadProgressEvent extends Event {
		
		public static const MATCH_PARSE_PROGRESS:String = "matchParseProgress"; 
		public static const MATCH_PARSE_COMPLETE:String = "matchParseComplete";
		public static const GAME_PARSE_PROGRESS:String = "gameParseProgress";
		public static const GAME_PARSE_COMPLETE:String = "gameParseComplete";
		
		public var itemsComplete:uint = 0;
		public var itemsTotal:uint = 0;
		
		public function MatchLoadProgressEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, itemsComplete:uint=0, itemsTotal:uint=0) { 
			super(type, bubbles, cancelable);
			this.itemsComplete = itemsComplete;
			this.itemsTotal = itemsTotal;
		}
		
		public override function clone():Event {
			return new MatchLoadProgressEvent(type, bubbles, cancelable, itemsComplete, itemsTotal);
		}
		
		public override function toString():String { 
			return formatToString("MatchLoadProgressEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}