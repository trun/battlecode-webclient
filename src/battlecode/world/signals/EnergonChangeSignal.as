package battlecode.world.signals {

    public class EnergonChangeSignal implements Signal {
        private var robotIDs:Array; // uint[]
        private var energon:Array // Number[]

        public function EnergonChangeSignal(robotIDs:Array, energon:Array) {
            this.robotIDs = robotIDs;
            this.energon = energon;
        }

        public function getRobotIDs():Array {
            return robotIDs;
        }

        public function getEnergon():Array {
            return energon;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitEnergonChangeSignal(this);
        }

    }

}