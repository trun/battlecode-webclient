package battlecode.serial {
	import battlecode.common.Team;
	
	public class RoundStats {
		
		private var aPoints:uint, bPoints:uint;
		
		public function RoundStats(aPoints:uint, bPoints:uint) {
			this.aPoints = aPoints;
			this.bPoints = bPoints;
		}
		
		public function getPoints(team:String):uint {
			return (team == Team.A) ? aPoints : bPoints;
		}
		
	}
	
}