package battlecode.client.viewer.render {

    public class DrawAction {
        private var type:String;
        private var rounds:uint;

        public function DrawAction(type:String, rounds:uint) {
            this.type = type;
            this.rounds = rounds;
        }

        public function getType():String {
            return type;
        }

        public function getRounds():uint {
            return rounds;
        }

        public function decreaseRound():void {
            rounds = Math.max(0, rounds - 1);
        }

        public function clone():DrawAction {
            return new DrawAction(type, rounds);
        }

    }

}