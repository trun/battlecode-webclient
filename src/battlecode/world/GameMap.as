package battlecode.world {
    import battlecode.common.MapLocation;

    public class GameMap {
        private var width:uint, height:uint;
        private var origin:MapLocation;
        private var terrainTiles:Array; //TerrainTile[][]
        private var initialOre:Array; // Number[][]

        public function GameMap(width:uint, height:uint, origin:MapLocation, terrainTiles:Array, initialOre:Array) {
            this.width = width;
            this.height = height;
            this.origin = origin;
            this.terrainTiles = terrainTiles;
            this.initialOre = initialOre;
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

        public function getTerrainTiles():Array {
            return terrainTiles;
        }

        public function getInitialOre():Array {
            return initialOre;
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

    }

}