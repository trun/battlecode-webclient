package battlecode.world {
	import battlecode.common.MapLocation;
	
	public class GameMap {
		
		private var width:uint, height:uint;
		
		private var origin:MapLocation;
		private var terrain:Array; // TerrainTile[][]
		private var fluxMineOffsetsX:Array;
		private var fluxMineOffsetsY:Array;
		
		public function GameMap(width:uint, height:uint, origin:MapLocation, terrain:Array) {
			this.width = width;
			this.height = height;
			this.origin = origin;
			this.terrain = terrain;
			this.computeFluxMineOffsets360(5);
		}
		
		public function getWidth():uint { 
			return width;
		}
		
		public function getHeight():uint {
			return height;
		}
		
		public function getOrigin():MapLocation {
			return origin;
		}
		
		public function getTerrainTileMatrix():Array {
			return terrain;
		}
		
		public function isOnMap(loc:MapLocation):Boolean {
			var x:int = loc.getX() - origin.getX();
			var y:int = loc.getY() - origin.getY();
			if (x < 0 || x >= width)
				return false;
			if (y < 0 || y >= height)
				return false;
			return true;
		}
		
		public function getFluxMineOffsets360():Array {
			return [ fluxMineOffsetsX, fluxMineOffsetsY ];
		}
		
		private function computeFluxMineOffsets360(radiusSquared:uint):void {
			var xOffsets:Array = new Array(400);
			var yOffsets:Array = new Array(400);
			var nOffsets:uint = 0;
			for (var y:int = 0; y * y <= radiusSquared; y++) {
				xOffsets[nOffsets] = 0;
				yOffsets[nOffsets] = y;
				nOffsets++;
				if (y > 0) {
					xOffsets[nOffsets] = 0;
					yOffsets[nOffsets] = -y;
					nOffsets++;
				}
				for (var x:int = 1; x*x + y*y <= radiusSquared; x++) {
					xOffsets[nOffsets] = x;
					yOffsets[nOffsets] = y;
					nOffsets++;
					xOffsets[nOffsets] = -x;
					yOffsets[nOffsets] = y;
					nOffsets++;
					if (y > 0) {
						xOffsets[nOffsets] = x;
						yOffsets[nOffsets] = -y;
						nOffsets++;
						xOffsets[nOffsets] = -x;
						yOffsets[nOffsets] = -y;
						nOffsets++;
					}
				}
			}
			fluxMineOffsetsX = xOffsets.slice(0, nOffsets);
			fluxMineOffsetsY = yOffsets.slice(0, nOffsets);
		}
		
	}
	
}