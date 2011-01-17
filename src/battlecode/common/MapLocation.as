package battlecode.common {
	
	public class MapLocation {
		
		private var x:uint;
		private var y:uint;
		
		public function MapLocation(x:uint, y:uint) {
			this.x = x;
			this.y = y;
		}
		
		public function getX():uint {
			return x;
		}
		
		public function getY():uint {
			return y;
		}
		
		public function add(dir:Direction):MapLocation {
			switch (dir) {
				case Direction.NORTH_EAST: return new MapLocation(x+1, y-1);
				case Direction.NORTH_WEST: return new MapLocation(x-1, y-1);
				case Direction.SOUTH_EAST: return new MapLocation(x+1, y+1);
				case Direction.SOUTH_WEST: return new MapLocation(x-1, y+1);
				case Direction.NORTH: return new MapLocation(x, y-1);
				case Direction.SOUTH: return new MapLocation(x, y+1);
				case Direction.EAST: return new MapLocation(x+1, y);
				case Direction.WEST: return new MapLocation(x-1, y);
				default: return new MapLocation(x, y);
			}
		}
		
		public function equals(o:MapLocation):Boolean {
			return x == o.x && y == o.y;
		}
		
	}
	
}