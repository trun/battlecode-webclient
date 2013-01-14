package battlecode.serial {
    import battlecode.common.Team;

    public class RoundStats {
        private var aPoints:Number, bPoints:Number;
        private var gatheredPointsA:Number, gatheredPointsB:Number;

        public function RoundStats(aPoints:Number, bPoints:Number, gatheredPointsA:Number, gatheredPointsB:Number) {
            this.aPoints = aPoints;
            this.bPoints = bPoints;
            this.gatheredPointsA = gatheredPointsA;
            this.gatheredPointsB = gatheredPointsB;
        }

        public function getPoints(team:String):Number {
            return (team == Team.A) ? aPoints : bPoints;
        }

        public function getGatheredPoints(team:String):Number {
            return (team == Team.A) ? gatheredPointsA : gatheredPointsB;
        }

    }

}