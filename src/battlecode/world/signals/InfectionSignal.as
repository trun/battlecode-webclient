package battlecode.world.signals {
    public class InfectionSignal implements Signal {
        private var robotIDs:Array; // uint[]
        private var zombieTurns:Array; // uint[]
        private var viperTurns:Array; // uint[]

        public function InfectionSignal(robotIDs:Array, zombieTurns:Array, viperTurns:Array) {
            this.robotIDs = robotIDs;
            this.zombieTurns = zombieTurns;
            this.viperTurns = viperTurns;
        }

        public function getRobotIDs():Array {
            return robotIDs;
        }

        public function getZombieTurns():Array {
            return zombieTurns;
        }

        public function getViperTurns():Array {
            return viperTurns;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitInfectionSignal(this);
        }

    }
}