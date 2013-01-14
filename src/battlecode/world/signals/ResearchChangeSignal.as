package battlecode.world.signals {

    public class ResearchChangeSignal implements Signal {
        private var progressA:Array;
        private var progressB:Array;

        public function ResearchChangeSignal(progressA:Array, progressB:Array) {
            this.progressA = progressA;
            this.progressB = progressB;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitResearchChangeSignal(this);
        }

    }

}