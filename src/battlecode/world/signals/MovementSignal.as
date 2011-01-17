package battlecode.world.signals {
	import battlecode.common.MapLocation;
	import battlecode.world.signals.SignalHandler;
	
	public class MovementSignal implements Signal {
		
		private var robotID:uint;
		private var targetLoc:MapLocation;
		private var movingForward:Boolean;
		
		public function MovementSignal(robotID:uint, targetLoc:MapLocation, movingForward:Boolean) {
			this.robotID = robotID;
			this.targetLoc = targetLoc;
			this.movingForward = movingForward;
		}
		
		public function getRobotID():uint {
			return robotID;
		}
		
		public function getTargetLoc():MapLocation {
			return targetLoc;
		}
		
		public function isMovingForward():Boolean {
			return movingForward;
		}
		
		public function accept(handler:SignalHandler):* {
			return handler.visitMovementSignal(this);
		}
		
	}
	
}