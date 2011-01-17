package battlecode.world.signals {
	import battlecode.world.signals.SignalHandler;
	
	public class SetDirectionSignal implements Signal {
		
		private var robotID:uint;
		private var dir:String;
		
		public function SetDirectionSignal(robotID:uint, dir:String) {
			this.robotID = robotID;
			this.dir = dir;
		}
		
		public function getRobotID():uint {
			return robotID;
		}
		
		public function getDirection():String {
			return dir;
		}
		
		public function accept(handler:SignalHandler):* {
			return handler.visitSetDirectionSignal(this);
		}
		
	}
	
}