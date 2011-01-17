package battlecode.world.signals {
	import battlecode.world.signals.Signal;
	import battlecode.world.signals.SignalHandler;
	
	public class UndeploySignal implements Signal {
		
		private var robotID:uint;
		
		public function UndeploySignal(robotID:uint) {
			this.robotID = robotID;
		}
		
		public function getRobotID():uint {
			return robotID;
		}
		
		public function accept(handler:SignalHandler):* {
			handler.visitUndeploySignal(this);
		}
		
	}

}