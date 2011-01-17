package battlecode.world.signals {
	import battlecode.common.MapLocation;
	import battlecode.world.signals.SignalHandler;
	
	public class AttackSignal implements Signal {
		
		private var robotID:uint;
		private var targetLoc:MapLocation;
		private var targetLevel:String;
		
		public function AttackSignal(robotID:uint, targetLoc:MapLocation, targetLevel:String) {
			this.robotID = robotID;
			this.targetLoc = targetLoc;
			this.targetLevel = targetLevel;
		}
		
		public function getRobotID():uint {
			return robotID;
		}
		
		public function getTargetLoc():MapLocation {
			return targetLoc;
		}
		
		public function getTargetLevel():String {
			return targetLevel;
		}
		
		public function accept(handler:SignalHandler):* {
			return handler.visitAttackSignal(this);
		}
		
	}
	
}