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
        private var deltas:Array; // RoundDelta[]
        private var stats:Array; // RoundStats[]

        private var teamA:String, teamB:String, winner:String;
        private var mapName:String;
        private var nukeA:Boolean = false, nukeB:Boolean = false;

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

            // map terrain tiles
            var terrainTiles:Array = new Array(mapHeight);
            for (var i:int = 0; i < mapHeight; i++) {
                terrainTiles[i] = new Array(mapWidth);
                for (var j:int = 0; j < mapWidth; j++) {
                    terrainTiles[i][j] = new TerrainTile(TerrainTile.LAND);
                }
            }

            gameMap = new GameMap(mapWidth, mapHeight, new MapLocation(mapOriginX, mapOriginY), terrainTiles);

            maxRounds = parseInt(mapXml.attribute("maxRounds"));
        }

        public function setExtensibleMetadata(xml:XML):void {
            teamA = xml.attribute("team-a").toString();
            teamB = xml.attribute("team-b").toString();
            mapName = xml.attribute("maps").toString().split(",")[matchNum]; // TODO
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

            var gatheredPoints:Array = xml.attribute("gatheredPoints").toString().split(",");
            var gatheredPointsA:Number = parseFloat(gatheredPoints[0]);
            var gatheredPointsB:Number = parseFloat(gatheredPoints[1]);
            stats.push(new RoundStats(pointsA, pointsB, gatheredPointsA, gatheredPointsB));
        }

        public function build():Match {
            return new Match(gameMap, deltas, stats, teamA, teamB, mapName, winner, maxRounds, nukeA, nukeB);
        }

    }

}
