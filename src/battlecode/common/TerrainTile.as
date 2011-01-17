package battlecode.common {
	
	public class TerrainTile {
		
		private var type:String;
		private var height:uint;
		
		public static const LAND:String = "LAND";
		public static const VOID:String = "VOID";
		public static const OFF_MAP:String = "OFF_MAP";
		
		public function TerrainTile(type:String, height:uint) {
			this.type = type;
			this.height = height;
		}
		
		public function getType():String {
			return type;
		}
		
		public function getHeight():uint {
			return height;
		}
		
	}
	
}