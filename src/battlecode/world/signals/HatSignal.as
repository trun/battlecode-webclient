package battlecode.world.signals {
    import battlecode.common.MapLocation;

    public class HatSignal implements Signal {
        private var robotID:uint;
        private var hat:int;

        public function HatSignal(robotID:uint, hat:int) {
            this.robotID = robotID;
            this.hat = hat;
        }

        public function getRobotID():uint {
            return robotID;
        }

        public function getHat():int {
            return hat;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitHatSignal(this);
        }

    }

}