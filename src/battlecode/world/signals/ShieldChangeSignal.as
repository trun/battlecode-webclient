package battlecode.world.signals {

    public class ShieldChangeSignal implements Signal {
        private var robotIDs:Array; // uint[]
        private var shields:Array // Number[]

        public function ShieldChangeSignal(robotIDs:Array, shields:Array) {
            this.robotIDs = robotIDs;
            this.shields = shields;
        }

        public function getRobotIDs():Array {
            return robotIDs;
        }

        public function getShields():Array {
            return shields;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitShieldChangeSignal(this);
        }

    }

}