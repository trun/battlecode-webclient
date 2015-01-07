package battlecode.serial {
    import battlecode.common.Team;

    public class RoundStats {
        private var aPoints:Number, bPoints:Number;

        public function RoundStats(aPoints:Number, bPoints:Number) {
            this.aPoints = aPoints;
            this.bPoints = bPoints;
        }

        public function getPoints(team:String):Number {
            return (team == Team.A) ? aPoints : bPoints;
        }
    }

}