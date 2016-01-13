package battlecode.serial {
    import battlecode.common.MapLocation;
    import battlecode.common.TerrainTile;
    import battlecode.world.GameMap;
    import battlecode.world.signals.Signal;
    import battlecode.world.signals.SignalFactory;

import flash.xml.XMLNode;

    public class MatchBuilder {
        private var matchNum:int = 0;
        private var gameMap:GameMap;
        private var maxRounds:uint;
        private var maxInitialOre:uint;
        private var deltas:Array; // RoundDelta[]
        private var stats:Array; // RoundStats[]

        private var teamA:String, teamB:String;
        private var nameA:String, nameB:String;
        private var winner:String;
        private var mapName:String;

        public function MatchBuilder() {
            deltas = [];
            stats = [];
        }

        public function setHeader(xml:XML):void {
            matchNum = parseInt(xml.attribute("matchNumber"));

            var mapXml:XMLList = xml.child("map");
            var mapWidth:int = parseInt(mapXml.attribute("width"));
            var mapHeight:int = parseInt(mapXml.attribute("height"));
            var mapOrigin:MapLocation = ParseUtils.parseLocation(mapXml.attribute("origin"));

            var i:int, j:int;
            var row:String;

            // map terrain tiles -- 2016 all tiles are LAND
            var terrainTiles:Array = new Array(mapHeight);
            for (i = 0; i < mapHeight; i++) {
                terrainTiles[i] = new Array(mapWidth);
                for (j = 0; j < mapWidth; j++) {
                    terrainTiles[i][j] = new TerrainTile(TerrainTile.LAND);
                }
            }

            var rubbleAmounts:Array = new Array(mapHeight);
            for (i = 0; i < mapHeight; i++) {
                rubbleAmounts[i] = new Array(mapWidth);
            }

            var rubbleXml:XMLList = mapXml.child("initialRubble");
            i = 0;
            for each (var rubbleRow:XML in rubbleXml.children()) {
                var rubbleValues:Array = rubbleRow.text().toString().split(",");
                rubbleValues = rubbleValues.map(function (element:*, index:int, arr:Array):uint {
                    return parseFloat(element);
                });
                for (j = 0; j < mapWidth; j++) {
                    rubbleAmounts[i][j] = rubbleValues[j];
                }
                i++;
            }

            var partsAmounts:Array = new Array(mapHeight);
            for (i = 0; i < mapHeight; i++) {
                partsAmounts[i] = new Array(mapWidth);
            }

            var partsXml:XMLList = mapXml.child("initialParts");
            i = 0;
            for each (var partsRow:XML in partsXml.children()) {
                var partsValues:Array = partsRow.text().toString().split(",");
                partsValues = partsValues.map(function (element:*, index:int, arr:Array):uint {
                    return parseFloat(element);
                });
                for (j = 0; j < mapWidth; j++) {
                    partsAmounts[i][j] = partsValues[j];
                }
                i++;
            }

            gameMap = new GameMap(mapWidth, mapHeight, mapOrigin, terrainTiles, rubbleAmounts, partsAmounts);

            maxRounds = parseInt(mapXml.attribute("rounds"));
        }

        public function setTeamNames(nameA:String, nameB:String):void {
            this.nameA = nameA;
            this.nameB = nameB;
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
            return new Match(gameMap, deltas, stats, teamA, teamB, nameA, nameB, mapName, winner, maxRounds, maxInitialOre);
        }

    }

}
