package battlecode.world.signals {
	import battlecode.common.MapLocation;
	import battlecode.world.signals.SignalHandler;
	
	public class MovementSignal implements Signal {
		
		private var robotID:uint;
		private var targetLoc:MapLocation;

		public function MovementSignal(robotID:uint, targetLoc:MapLocation) {
			this.robotID = robotID;
			this.targetLoc = targetLoc;
		}
		
		public function getRobotID():uint {
			return robotID;
		}
		
		public function getTargetLoc():MapLocation {
			return targetLoc;
		}
		
		public function accept(handler:SignalHandler):* {
			return handler.visitMovementSignal(this);
		}
		
	}
	
}