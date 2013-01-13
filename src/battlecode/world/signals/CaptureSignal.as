package battlecode.world.signals {
	import battlecode.common.MapLocation;
	import battlecode.world.signals.SignalHandler;

	public class CaptureSignal implements Signal {
		
		private var robotID:uint;
		private var parentID:uint;
		private var loc:MapLocation;
		private var type:String;
		private var team:String;
        private var handling:Boolean;

		public function CaptureSignal(robotID:uint, parentID:uint, loc:MapLocation, type:String, team:String, handling:Boolean) {
			this.robotID = robotID;
			this.parentID = parentID;
			this.loc = loc;
			this.type = type;
			this.team = team;
            this.handling = handling;
		}
		
		public function getRobotID():uint {
			return robotID;
		}
		
		public function getParentID():uint {
			return parentID;
		}
		
		public function getLocation():MapLocation {
			return loc;
		}
		
		public function getRobotType():String {
			return type;
		}
		
		public function getTeam():String {
			return team;
		}

        public function hasHandling():Boolean {
            return handling;
        }
		
		public function accept(handler:SignalHandler):* {
			return handler.visitCaptureSignal(this);
		}
		
	}
	
}