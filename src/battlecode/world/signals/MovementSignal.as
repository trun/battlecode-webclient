package battlecode.world.signals {
    import battlecode.common.MapLocation;

    public class MovementSignal implements Signal {
        private var robotID:uint;
        private var targetLoc:MapLocation;
        private var movementType:String;
        private var delay:uint;

        public function MovementSignal(robotID:uint, targetLoc:MapLocation, movementType:String, delay:uint) {
            this.robotID = robotID;
            this.targetLoc = targetLoc;
            this.movementType = movementType;
            this.delay = delay;
        }

        public function getRobotID():uint {
            return robotID;
        }

        public function getTargetLoc():MapLocation {
            return targetLoc;
        }

        public function getMovementType():String {
            return movementType;
        }

        public function getDelay():uint {
            return delay;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitMovementSignal(this);
        }

    }

}