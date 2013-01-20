package battlecode.world.signals {
    import battlecode.common.Team;

    public class ResearchChangeSignal implements Signal {
        private var progressA:Array;
        private var progressB:Array;

        public function ResearchChangeSignal(progressA:Array, progressB:Array) {
            this.progressA = progressA;
            this.progressB = progressB;
        }

        public function getProgress(team:String):Array {
            return team == Team.A ? progressA : progressB;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitResearchChangeSignal(this);
        }

    }

}