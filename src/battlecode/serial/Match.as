package battlecode.serial {
    import battlecode.world.GameMap;

    import flash.events.EventDispatcher;

    public class Match extends EventDispatcher {
        private var gameMap:GameMap;
        private var rounds:uint;
        private var maxRounds:uint;
        private var winner:String;
        private var deltas:Array; // RoundDelta[]
        private var stats:Array; // RoundStats[]

        private var teamA:String, teamB:String;
        private var mapName:String;

        public function Match(gameMap:GameMap, deltas:Array, stats:Array, teamA:String, teamB:String, mapName:String, winner:String, maxRounds:uint) {
            this.gameMap = gameMap;
            this.deltas = deltas;
            this.stats = stats;
            this.teamA = teamA;
            this.teamB = teamB;
            this.mapName = mapName;
            this.winner = winner;
            this.rounds = deltas.length;
            this.maxRounds = maxRounds;
        }

        public function getMap():GameMap {
            return gameMap;
        }

        public function getRounds():uint {
            return rounds;
        }

        public function getMaxRounds():uint {
            return maxRounds;
        }

        public function getWinner():String {
            return winner;
        }

        public function getTeamA():String {
            return teamA;
        }

        public function getTeamB():String {
            return teamB;
        }

        public function getMapName():String {
            return mapName;
        }

        public function getRoundDelta(round:uint):RoundDelta {
            return deltas[round] as RoundDelta;
        }

        public function getRoundStats(round:uint):RoundStats {
            return stats[round] as RoundStats;
        }

    }

}