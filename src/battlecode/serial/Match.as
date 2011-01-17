package battlecode.serial {
	import battlecode.common.MapLocation;
	import battlecode.common.TerrainTile;
	import battlecode.events.MatchLoadProgressEvent;
	import battlecode.world.GameMap;
	import battlecode.world.signals.Signal;
	import battlecode.world.signals.SignalFactory;
	import flash.errors.MemoryError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import mx.controls.Alert;
	
	[Event(name="gameParseProgress", type="battlecode.events.MatchLoadProgressEvent")]
	[Event(name="gameParseComplete", type="battlecode.events.MatchLoadProgressEvent")]
	public class Match extends EventDispatcher {
		
		private var gameMap:GameMap;
		private var rounds:uint;
		private var maxRounds:uint;
		private var minPoints:uint;
		private var winner:String;
		private var deltas:Array; // RoundDelta[]
		private var stats:Array; // RoundStats[]
		
		private var teamA:String, teamB:String;
		private var map:String;
		
		// progress parsing
		private var roundElement:XMLList;
		private var statsElement:XMLList;
		
		private const ROUNDS_TO_PARSE:uint = 100; // number of rounds to parse on each tick
		private var currentRound:uint = 0; // next round to parse
		private var parseTimer:Timer;
		
		public function Match(xml:XML=null) {
			if (xml) parseMatch(xml, false);
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
		
		public function getStraightMaxRounds():uint {
			return maxRounds - 2000;
		}
		
		public function getMinPoints():uint {
			return minPoints;
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
			return map;
		}
		
		public function getRoundDelta(round:uint):RoundDelta {
			return deltas[round] as RoundDelta;
		}
		
		public function getRoundStats(round:uint):RoundStats {
			return stats[round] as RoundStats;
		}
		
		public function parseMatch(xml:XML, useProgress:Boolean = true):void {
			var mapElement:XMLList = xml.child("map");
			var metadataElement:XMLList = xml.child("metadata");
			var footerElement:XMLList = xml.child("footer");
			roundElement = xml.child("round");
			statsElement = xml.child("stats");
			
			var i:uint, j:uint;
			var row:String;
			
			// map info
			var mapInfo:XMLList = mapElement.child("info");
			var mapWidth:uint = parseInt(mapInfo.attribute("width"));
			var mapHeight:uint = parseInt(mapInfo.attribute("height"));
			var mapMaxRounds:uint = parseInt(mapInfo.attribute("rounds"));
			var mapMinPoints:uint = parseInt(mapInfo.attribute("points"));
			var mapOrigin:MapLocation = ParseUtils.parseLocation(mapInfo.attribute("origin"));
			
			// map terrain
			var terrainStr:String = mapElement.child("terrain");
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
					terrainTypes[i][j] = (row.charAt(j) == "#") ? TerrainTile.VOID : TerrainTile.LAND;
				}
			}
			
			// map terrain heights
			var heightStr:String = mapElement.child("height");
			var heightRows:Array = heightStr.split("\n");
			var heights:Array = new Array(mapHeight);
			for (i = 0; i < mapHeight; i++) {
				heights[i] = new Array(mapWidth);
				row = ParseUtils.trim(heightRows[i]);
				if (row == "") {
					heightRows.splice(i, 1);
					i--;
					continue;
				}
				for (j = 0; j < mapWidth; j++) {
					heights[i][j] = parseInt(row.charAt(j), 36);
				}
			}
			
			// map terrain tiles
			var terrainTiles:Array = new Array(mapHeight);
			for (i = 0; i < mapHeight; i++) {
				terrainTiles[i] = new Array(mapWidth);
				for (j = 0; j < mapWidth; j++) {
					terrainTiles[i][j] = new TerrainTile(terrainTypes[i][j], heights[i][j]);
				}
			}
			
			// game map and match info
			gameMap = new GameMap(mapWidth, mapHeight, mapOrigin, terrainTiles);
			maxRounds = mapMaxRounds; // use actual max number of rounds instead
			minPoints = mapMinPoints;
			
			// match winner
			winner = footerElement.attribute("winner").toString();
			
			//metadata
			teamA = metadataElement.attribute("teamA").toString();
			teamB = metadataElement.attribute("teamB").toString();
			map = metadataElement.attribute("map").toString();
			
			// signals
			var numRounds:uint = roundElement.length();
			deltas = new Array(numRounds);
			rounds = numRounds;

			// stats
			var numStats:uint = statsElement.length();
			stats = new Array(numStats);
			
			parseTimer = new Timer(30);
			parseTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
			parseTimer.start();
		}
		
		private function onTimerTick(e:TimerEvent):void {
			try {
				for (var i:uint = currentRound; i < Math.min(rounds, currentRound + ROUNDS_TO_PARSE); i++) {
					// signals
					var signalList:XMLList = roundElement[i].children();
					var numSignals:uint = signalList.length();
					var roundSignals:Array = new Array(numSignals);
					for (var j:uint = 0; j < numSignals; j++) {
						roundSignals[j] = SignalFactory.createSignal(signalList[j]);
					}
					deltas[i] = new RoundDelta(roundSignals);
					
					// stats
					var aPoints:uint = parseInt(statsElement[i].attribute("aPoints"));
					var bPoints:uint = parseInt(statsElement[i].attribute("bPoints"));
					stats[i] = new RoundStats(aPoints, bPoints);
				}
				
				currentRound = Math.min(currentRound + ROUNDS_TO_PARSE, rounds);
				
				var progressEvent:MatchLoadProgressEvent = new MatchLoadProgressEvent(MatchLoadProgressEvent.GAME_PARSE_PROGRESS);
				progressEvent.itemsComplete = currentRound;
				progressEvent.itemsTotal = rounds;
				dispatchEvent(progressEvent);
				
				if (currentRound >= rounds) {
					roundElement = null;
					statsElement = null;
					parseTimer.stop();
					dispatchEvent(new MatchLoadProgressEvent(MatchLoadProgressEvent.GAME_PARSE_COMPLETE));
				}
			} catch (e:MemoryError) {
				Alert.show("Memory allocation error: " + e.message);
			}
		}
		
	}
	
}