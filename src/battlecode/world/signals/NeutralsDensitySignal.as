package battlecode.world.signals {
    public class NeutralsDensitySignal implements Signal {
        private var amounts:Array; // int[][]

        public function NeutralsDensitySignal(amounts:Array) {
            this.amounts = amounts;
        }

        public function getAmounts():Array {
            return amounts;
        }

        public function getAmount(x:uint, y:uint):int {
            return amounts[x][y];
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitNeutralsDensitySignal(this);
        }
    }
}
