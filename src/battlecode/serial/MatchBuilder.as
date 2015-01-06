package battlecode.serial {
    import battlecode.common.MapLocation;
    import battlecode.common.TerrainTile;
    import battlecode.world.GameMap;
    import battlecode.world.signals.Signal;
    import battlecode.world.signals.SignalFactory;

    public class MatchBuilder {
        private var matchNum:int = 0;
        private var gameMap:GameMap;
        private var maxRounds:uint;
        private var maxInitialOre:uint;
        private var deltas:Array; // RoundDelta[]
        private var stats:Array; // RoundStats[]

        private var teamA:String, teamB:String, winner:String;
        private var mapName:String;

        public function MatchBuilder() {
            deltas = [];
            stats = [];
        }

        public function setHeader(xml:XML):void {
            matchNum = parseInt(xml.attribute("matchNumber"));

            var mapXml:XMLList = xml.child("map");
            var mapWidth:int = parseInt(mapXml.attribute("mapWidth"));
            var mapHeight:int = parseInt(mapXml.attribute("mapHeight"));
            var mapOriginX:int = parseInt(mapXml.attribute("mapOriginX"));
            var mapOriginY:int = parseInt(mapXml.attribute("mapOriginY"));

            var i:int, j:int;
            var row:String;

            // map terrain
            var terrainStr:String = mapXml.child("mapTiles");
            var terrainRows:Array = terrainStr.split("\n");
            var terrainTypes:Array = new Array(mapHeight);
            for (i = 0; i < mapHeight; i++) {
                terrainTypes[i] = new Array(mapWidth);
                row = ParseUtils.trim(terrainRows[i]);
                if (row == "") {
                    terrainRows.splice(i, 1);
                    i--;
                    continue;
                }
                for (j = 0; j < mapWidth; j++) {
                    switch (row.charAt(j)) {
                        case '#':
                            terrainTypes[i][j] = TerrainTile.VOID;
                            break;
                        default:
                            terrainTypes[i][j] = TerrainTile.LAND;
                            break;
                    }
                }
            }

            // map terrain tiles
            var terrainTiles:Array = new Array(mapHeight);
            for (i = 0; i < mapHeight; i++) {
                terrainTiles[i] = new Array(mapWidth);
                for (j = 0; j < mapWidth; j++) {
                    terrainTiles[i][j] = new TerrainTile(terrainTypes[i][j]);
                }
            }

            // map ore tiles TODO - parse mapInitialOre
            var oreAmounts:Array = new Array(mapHeight);
            for (i = 0; i < mapHeight; i++) {
                oreAmounts[i] = new Array(mapWidth);
                for (j = 0; j < mapWidth; j++) {
                    oreAmounts[i][j] = 0;
                }
            }

            gameMap = new GameMap(mapWidth, mapHeight, new MapLocation(mapOriginX, mapOriginY), terrainTiles);

            maxRounds = parseInt(mapXml.attribute("maxRounds"));
            maxInitialOre = parseInt(mapXml.attribute("maxInitialOre"));
        }

        public function setExtensibleMetadata(xml:XML):void {
            teamA = xml.attribute("team-a").toString();
            teamB = xml.attribute("team-b").toString();
            mapName = xml.attribute("maps").toString().split(",")[matchNum];
        }

        public function setGameStats(xml:XML):void {
            // TODO
        }

        public function setFooter(xml:XML):void {
            winner = xml.attribute("winner").toString();
        }

        public function addRoundDelta(xml:XML):void {
            var signalXml:XMLList = xml.children();
            var signals:Array = [];
            for each (var signalXML:XML in signalXml) {
                var signal:Signal = SignalFactory.createSignal(signalXML);
                signals.push(signal);
            }
            deltas.push(new RoundDelta(signals));
        }

        public function addRoundStats(xml:XML):void {
            var points:Array = xml.attribute("points").toString().split(",");
            var pointsA:Number = parseFloat(points[0]);
            var pointsB:Number = parseFloat(points[1]);
            stats.push(new RoundStats(pointsA, pointsB));
        }

        public function build():Match {
            return new Match(gameMap, deltas, stats, teamA, teamB, mapName, winner, maxRounds, maxInitialOre);
        }

    }

}
