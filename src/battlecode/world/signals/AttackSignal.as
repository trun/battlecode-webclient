package battlecode.world.signals {
    import battlecode.common.AttackType;
    import battlecode.common.MapLocation;

    public class AttackSignal implements Signal {
        private var robotID:uint;
        private var targetLoc:MapLocation;
        private var attackType:String;

        public function AttackSignal(robotID:uint, targetLoc:MapLocation, attackType:String) {
            this.robotID = robotID;
            this.targetLoc = targetLoc;
            this.attackType = attackType;
        }

        public function getRobotID():uint {
            return robotID;
        }

        public function getTargetLoc():MapLocation {
            return targetLoc;
        }

        public function getAttackType():String {
            return attackType;
        }

        public function isLight():Boolean {
            return attackType == AttackType.LIGHT;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitAttackSignal(this);
        }

    }

}