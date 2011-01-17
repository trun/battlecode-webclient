package battlecode.events {
	import battlecode.client.viewer.render.DrawRobot;
	import flash.events.Event;
	
	public class RobotEvent extends Event {
		
		public static const INDICATOR_STRING_CHANGE:String = "indicatorStringChange";
		
		private var robot:DrawRobot;
		
		public function RobotEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, robot:DrawRobot=null) { 
			super(type, bubbles, cancelable);
			this.robot = robot;
		} 
		
		public override function clone():Event { 
			return new RobotEvent(type, bubbles, cancelable, robot);
		} 
		
		public override function toString():String { 
			return formatToString("RobotEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}