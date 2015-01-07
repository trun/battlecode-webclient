package battlecode.client.viewer.render {

    public class DrawAction {
        private var type:String;
        private var rounds:uint;
        private var maxRounds:uint;

        public function DrawAction(type:String, rounds:uint, maxRounds:*=null) {
            this.type = type;
            this.rounds = rounds;
            this.maxRounds = maxRounds != null ? maxRounds : rounds;
        }

        public function getType():String {
            return type;
        }

        public function getRounds():uint {
            return rounds;
        }

        public function getMaxRounds():uint {
            return maxRounds;
        }

        public function decreaseRound():void {
            rounds = Math.max(0, rounds - 1);
        }

        public function clone():DrawAction {
            return new DrawAction(type, rounds, maxRounds);
        }

    }

}