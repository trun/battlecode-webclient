package battlecode.world.signals {
    import battlecode.common.AttackType;
    import battlecode.common.MapLocation;

    public class RobotInfoSignal implements Signal {
        private var robotID:uint;
        private var health:Number;

        public function RobotInfoSignal(robotID:uint, health:Number) {
            this.robotID = robotID;
            this.health = health;
        }

        public function getRobotID():uint {
            return robotID;
        }

        public function getHealth():Number {
            return health;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitRobotInfoSignal(this);
        }

    }

}