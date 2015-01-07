package battlecode.world.signals {
    import battlecode.common.MapLocation;

    public class SpawnSignal implements Signal {
        private var robotID:uint;
        private var parentID:uint;
        private var loc:MapLocation;
        private var type:String;
        private var team:String;
        private var delay:uint;

        public function SpawnSignal(robotID:uint, parentID:uint, loc:MapLocation, type:String, team:String, delay:uint) {
            this.robotID = robotID;
            this.parentID = parentID;
            this.loc = loc;
            this.type = type;
            this.team = team;
            this.delay = delay;
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

        public function getDelay():uint {
            return delay;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitSpawnSignal(this);
        }

    }

}