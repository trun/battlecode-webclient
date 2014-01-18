package battlecode.world.signals {
    import battlecode.common.Team;

    public class NeutralsTeamSignal implements Signal {
        private var teams:Array; // int[][]

        public function NeutralsTeamSignal(teams:Array) {
            this.teams = teams;
        }

        public function getTeams():Array {
            return teams;
        }

        public function getTeam(x:uint, y:uint):String {
            return Team.valueOf(teams[x][y]);
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitNeutralsTeamSignal(this);
        }
    }
}
