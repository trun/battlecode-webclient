package battlecode.world.signals {
    public class HealthChangeSignal implements Signal {
        private var robotIDs:Array; // uint[]
        private var healths:Array; // Number[]

        public function HealthChangeSignal(robotIDs:Array, healths:Array) {
            this.robotIDs = robotIDs;
            this.healths = healths;
        }

        public function getRobotIDs():Array {
            return robotIDs;
        }

        public function getHealths():Array {
            return healths;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitHealthChangeSignal(this);
        }

    }
}