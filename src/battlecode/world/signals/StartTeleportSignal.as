package battlecode.world.signals {
	import battlecode.common.MapLocation;
	import battlecode.world.signals.Signal;
	import battlecode.world.signals.SignalHandler;
	
	public class StartTeleportSignal implements Signal {
		
		private var robotID:uint;
		private var targetLoc:MapLocation;
		private var toTeleporterID:uint;
		private var fromTeleporterID:uint;
		
		public function StartTeleportSignal(robotID:uint, targetLoc:MapLocation, toTeleporterID:uint, fromTeleporterID:uint) {
			this.robotID = robotID;
			this.targetLoc = targetLoc;
			this.toTeleporterID = toTeleporterID;
			this.fromTeleporterID = fromTeleporterID;
		}
		
		public function getRobotID():uint {
			return robotID;
		}
		
		public function getTargetLoc():MapLocation {
			return targetLoc;
		}
		
		public function getToTeleporterID():uint {
			return toTeleporterID;
		}
		
		public function getFromTeleporterID():uint {
			return fromTeleporterID;
		}
		
		public function accept(handler:SignalHandler):* {
			handler.visitStartTeleportSignal(this);
		}
		
	}

}