package battlecode.serial {
    import battlecode.world.GameMap;

    import flash.events.EventDispatcher;

    public class Match extends EventDispatcher {
        private var gameMap:GameMap;
        private var rounds:uint;
        private var maxRounds:uint;
        private var winner:String;
        private var deltas:Array; // RoundDelta[]
        private var stats:Array; // RoundStats[]

        private var teamA:String, teamB:String;
        private var mapName:String;

        public function Match(gameMap:GameMap, deltas:Array, stats:Array, teamA:String, teamB:String, mapName:String, winner:String, maxRounds:uint) {
            this.gameMap = gameMap;
            this.deltas = deltas;
            this.stats = stats;
            this.teamA = teamA;
            this.teamB = teamB;
            this.mapName = mapName;
            this.winner = winner;
            this.rounds = deltas.length;
            this.maxRounds = maxRounds;
        }

        public function getMap():GameMap {
            return gameMap;
        }

        public function getRounds():uint {
            return rounds;
        }

        public function getMaxRounds():uint {
            return maxRounds;
        }

        public function getWinner():String {
            return winner;
        }

        public function getTeamA():String {
            return teamA;
        }

        public function getTeamB():String {
            return teamB;
        }

        public function getMapName():String {
            return mapName;
        }

        public function getRoundDelta(round:uint):RoundDelta {
            return deltas[round] as RoundDelta;
        }

        public function getRoundStats(round:uint):RoundStats {
            return stats[round] as RoundStats;
        }

//		public function parseMatch(xml:XML, useProgress:Boolean = true):void {
//			var mapElement:XMLList = xml.child("mapName");
//			var metadataElement:XMLList = xml.child("metadata");
//			var footerElement:XMLList = xml.child("footer");
//			roundElement = xml.child("round");
//			statsElement = xml.child("stats");
//
//			var i:uint, j:uint;
//			var row:String;
//
//			// map info
//			var mapInfo:XMLList = mapElement.child("info");
//			var mapWidth:uint = parseInt(mapInfo.attribute("width"));
//			var mapHeight:uint = parseInt(mapInfo.attribute("height"));
//			var mapMaxRounds:uint = parseInt(mapInfo.attribute("rounds"));
//			var mapMinPoints:uint = parseInt(mapInfo.attribute("points"));
//			var mapOrigin:MapLocation = ParseUtils.parseLocation(mapInfo.attribute("origin"));
//
//			// map terrain
//			var terrainStr:String = mapElement.child("terrain");
//			var terrainRows:Array = terrainStr.split("\n");
//			var terrainTypes:Array = new Array(mapHeight);
//			for (i = 0; i < mapHeight; i++) {
//				terrainTypes[i] = new Array(mapWidth);
//				row = ParseUtils.trim(terrainRows[i]);
//				if (row == "") {
//					terrainRows.splice(i, 1);
//					i--;
//					continue;
//				}
//				for (j = 0; j < mapWidth; j++) {
//					terrainTypes[i][j] = (row.charAt(j) == "#") ? TerrainTile.VOID : TerrainTile.LAND;
//				}
//			}
//
//			// map terrain heights
//			var heightStr:String = mapElement.child("height");
//			var heightRows:Array = heightStr.split("\n");
//			var heights:Array = new Array(mapHeight);
//			for (i = 0; i < mapHeight; i++) {
//				heights[i] = new Array(mapWidth);
//				row = ParseUtils.trim(heightRows[i]);
//				if (row == "") {
//					heightRows.splice(i, 1);
//					i--;
//					continue;
//				}
//				for (j = 0; j < mapWidth; j++) {
//					heights[i][j] = parseInt(row.charAt(j), 36);
//				}
//			}
//
//			// map terrain tiles
//			var terrainTiles:Array = new Array(mapHeight);
//			for (i = 0; i < mapHeight; i++) {
//				terrainTiles[i] = new Array(mapWidth);
//				for (j = 0; j < mapWidth; j++) {
//					terrainTiles[i][j] = new TerrainTile(terrainTypes[i][j], heights[i][j]);
//				}
//			}
//
//			// game map and match info
//			gameMap = new GameMap(mapWidth, mapHeight, mapOrigin, terrainTiles);
//			maxRounds = mapMaxRounds; // use actual max number of rounds instead
//			minPoints = mapMinPoints;
//
//			// match winner
//			winner = footerElement.attribute("winner").toString();
//
//			//metadata
//			teamA = metadataElement.attribute("teamA").toString();
//			teamB = metadataElement.attribute("teamB").toString();
//			mapName = metadataElement.attribute("mapName").toString();
//
//			// signals
//			var numRounds:uint = roundElement.length();
//			deltas = new Array(numRounds);
//			rounds = numRounds;
//
//			// stats
//			var numStats:uint = statsElement.length();
//			stats = new Array(numStats);
//
//			parseTimer = new Timer(30);
//			parseTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
//			parseTimer.start();
//		}

//		private function onTimerTick(e:TimerEvent):void {
//			try {
//				for (var i:uint = currentRound; i < Math.min(rounds, currentRound + ROUNDS_TO_PARSE); i++) {
//					// signals
//					var signalList:XMLList = roundElement[i].children();
//					var numSignals:uint = signalList.length();
//					var roundSignals:Array = new Array(numSignals);
//					for (var j:uint = 0; j < numSignals; j++) {
//						roundSignals[j] = SignalFactory.createSignal(signalList[j]);
//					}
//					deltas[i] = new RoundDelta(roundSignals);
//
//					// stats
//					var aPoints:uint = parseInt(statsElement[i].attribute("aPoints"));
//					var bPoints:uint = parseInt(statsElement[i].attribute("bPoints"));
//					stats[i] = new RoundStats(aPoints, bPoints);
//				}
//
//				currentRound = Math.min(currentRound + ROUNDS_TO_PARSE, rounds);
//
//				var progressEvent:MatchLoadProgressEvent = new MatchLoadProgressEvent(MatchLoadProgressEvent.GAME_PARSE_PROGRESS);
//				progressEvent.itemsComplete = currentRound;
//				progressEvent.itemsTotal = rounds;
//				dispatchEvent(progressEvent);
//
//				if (currentRound >= rounds) {
//					roundElement = null;
//					statsElement = null;
//					parseTimer.stop();
//					dispatchEvent(new MatchLoadProgressEvent(MatchLoadProgressEvent.GAME_PARSE_COMPLETE));
//				}
//			} catch (e:MemoryError) {
//				Alert.show("Memory allocation error: " + e.message);
//			}
//		}

    }

}