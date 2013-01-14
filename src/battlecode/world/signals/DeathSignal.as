package battlecode.world.signals {

    public class DeathSignal implements Signal {
        private var robotID:uint;

        public function DeathSignal(robotID:uint) {
            this.robotID = robotID;
        }

        public function getRobotID():uint {
            return robotID;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitDeathSignal(this);
        }

    }

}