package battlecode.world.signals {

    public class DeathSignal implements Signal {
        private var robotID:uint;
        private var deathByActivation:Boolean;

        public function DeathSignal(robotID:uint, deathByActivation:Boolean) {
            this.robotID = robotID;
            this.deathByActivation = deathByActivation;
        }

        public function getRobotID():uint {
            return robotID;
        }

        public function getDeathByActivation():Boolean {
            return deathByActivation;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitDeathSignal(this);
        }

    }

}