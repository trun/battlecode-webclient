package battlecode.common {
	
	public class Direction {
		
		public static const NORTH:String = "NORTH";
		public static const NORTH_EAST:String = "NORTH_EAST";
		public static const EAST:String = "EAST";
		public static const SOUTH_EAST:String = "SOUTH_EAST";
		public static const SOUTH:String = "SOUTH";
		public static const SOUTH_WEST:String = "SOUTH_WEST";
		public static const WEST:String = "WEST";
		public static const NORTH_WEST:String = "NORTH_WEST";
		public static const OMNI:String = "OMNI";
		public static const NONE:String = "NONE";
		
		private static var _values:Array = [ NORTH, NORTH_EAST, EAST, SOUTH_EAST, SOUTH, SOUTH_WEST, WEST, NORTH_WEST, OMNI, NONE ];
		
		public function Direction() { }
		
		public static function values():Array {
			return _values;
		}
		
		public static function ordinal(dir:String):uint {
			return _values.indexOf(dir);
		}
		
		public static function isDiagonal(dir:String):Boolean {
			switch (dir) {
				case NORTH_EAST:
				case NORTH_WEST:
				case SOUTH_EAST:
				case SOUTH_WEST:
					return true;
				default: return false;
			}
		}
		
		public static function opposite(dir:String):String {
			switch (dir) {
				case NORTH_EAST: return SOUTH_WEST;
				case NORTH_WEST: return SOUTH_EAST;
				case SOUTH_EAST: return NORTH_WEST;
				case SOUTH_WEST: return NORTH_EAST;
				case NORTH: return SOUTH;
				case SOUTH: return NORTH;
				case EAST: return WEST;
				case WEST: return EAST;
				default: return NONE;
			}
		}
		
	}
	
}