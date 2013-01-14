package battlecode.world.signals {

    public class MineLayerSignal implements Signal {
        private var robotID:uint;
        private var laying:Boolean;

        public function MineLayerSignal(robotID:uint, laying:Boolean) {
            this.robotID = robotID;
            this.laying = laying;
        }

        public function getRobotID():uint {
            return robotID;
        }

        public function isLaying():Boolean {
            return laying;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitMineLayerSignal(this);
        }
    }

}
