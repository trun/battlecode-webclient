package battlecode.world.signals {
	
	public class BroadcastSignal implements Signal {
		
		private var robotID:uint;
		
		public function BroadcastSignal(robotID:uint) {
			this.robotID = robotID;
		}
		
		public function getRobotID():uint {
			return robotID;
		}
		
		public function accept(handler:SignalHandler):* {
			return handler.visitBroadcastSignal(this);
		}
		
	}
	
}