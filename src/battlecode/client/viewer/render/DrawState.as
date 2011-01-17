package battlecode.client.viewer.render {
	import battlecode.common.MapLocation;
	import battlecode.common.RobotType;
	import battlecode.common.Team;
	import battlecode.serial.RoundDelta;
	import battlecode.serial.RoundStats;
	import battlecode.world.GameMap;
	import battlecode.world.signals.*;
	import flash.events.MouseEvent;
	import mx.core.UIComponent;
	
	public class DrawState extends DefaultSignalHandler {
		
		// state
		private var airRobots:Object;
		private var groundRobots:Object;
		private var archonsA:Array;
		private var archonsB:Array;
		private var convexHullsA:Array;
		private var convexHullsB:Array;
		private var flux:Array // uint[][]
		
		// stats
		private var aPoints:uint;
		private var bPoints:uint;
		private var roundNum:uint;
		
		// immutables
		private var map:GameMap;
		private var origin:MapLocation;
		private var fluxMineOffsetsX:Array;
		private var fluxMineOffsetsY:Array;
		
		public function DrawState(map:GameMap) {
			airRobots = new Object();
			groundRobots = new Object();
			archonsA = new Array();
			archonsB = new Array();
			convexHullsA = new Array();
			convexHullsB = new Array();
			
			flux = new Array(map.getHeight());
			for (var i:uint = 0; i < flux.length; i++) {
				flux[i] = new Array(map.getWidth());
				for (var j:uint = 0; j < flux[i].length; j++) {
					flux[i][j] = 0;
				}
			}
			
			aPoints = 0;
			bPoints = 0;
			roundNum = 1;
			
			this.map = map;
			this.origin = map.getOrigin();
			var offsets:Array = map.getFluxMineOffsets360();
			this.fluxMineOffsetsX = offsets[0];
			this.fluxMineOffsetsY = offsets[1];
		}
		
		///////////////////////////////////////////////////////
		///////////////// PROPERTY GETTERS ////////////////////
		///////////////////////////////////////////////////////
		
		public function getAirRobots():Object { return airRobots; }
		public function getGroundRobots():Object { return groundRobots; }
		public function getConvexHulls(team:String):Array { return (team == Team.A) ? convexHullsA : convexHullsB; }
		public function getArchons(team:String):Array { return (team == Team.A) ? archonsA : archonsB; }
		public function getPoints(team:String):uint { return (team == Team.A) ? aPoints : bPoints; }
		public function getFluxMatrix():Array { return flux; }
		
		///////////////////////////////////////////////////////
		/////////////////// CORE FUNCTIONS ////////////////////
		///////////////////////////////////////////////////////
		
		private function copyStateFrom(state:DrawState):void {
			var a:*;
			
			airRobots = new Object();
			for (a in state.airRobots) {
				airRobots[a] = state.airRobots[a].clone();
			}
			
			groundRobots = new Object();
			for (a in state.groundRobots) {
				groundRobots[a] = state.groundRobots[a].clone();
			}
			
			archonsA = new Array();
			for (a in state.archonsA) {
				archonsA[a] = state.archonsA[a].clone();
			}
			
			archonsB = new Array();
			for (a in state.archonsB) {
				archonsB[a] = state.archonsB[a].clone();
			}
			
			convexHullsA = state.convexHullsA.concat();
			convexHullsB = state.convexHullsB.concat();
			
			for (var i:uint = 0; i < flux.length; i++) {
				for (var j:uint = 0; j < flux[i].length; j++) {
					flux[i][j] = state.flux[i][j];
				}
			}
			
			roundNum = state.roundNum;
		}
		
		public function clone():DrawState {
			var state:DrawState = new DrawState(map);
			state.copyStateFrom(this);
			return state;
		}
		
		public function applyDelta(delta:RoundDelta):void {
			updateRound();
			for each(var signal:Signal in delta.getSignals()) {
				applySignal(signal);
			}
			processEndOfRound();
		}
		
		public function applySignal(signal:Signal):void {
			if (signal != null) signal.accept(this);
		}
		
		public function applyStats(stats:RoundStats):void {
			aPoints = stats.getPoints(Team.A);
			bPoints = stats.getPoints(Team.B);
		}
		
		public function updateRound():void {
			var a:*, i:uint, j:uint;
			var o:DrawRobot;
			
			for (a in airRobots) {
				o = airRobots[a] as DrawRobot;
				o.updateRound();
				if (!o.isAlive()) {
					if (o.parent) {
						o.parent.removeChild(o);
					}
					delete airRobots[a];
				}
			}
			
			for (a in groundRobots) {
				o = groundRobots[a] as DrawRobot;
				o.updateRound();
				if (!o.isAlive()) {
					if (o.parent) {
						o.parent.removeChild(o);
					}
					delete groundRobots[a];
				}
			}
			
			for (i = 0; i < archonsA.length; i++) {
				o = archonsA[i] as DrawRobot;
				o.updateRound();
				if (!o.isAlive()) {
					if (o.parent) {
						o.parent.removeChild(o);
					}
					archonsA.splice(i, 1);
					i--;
				}
			}
			
			for (i = 0; i < archonsB.length; i++) {
				o = archonsB[i] as DrawRobot;
				o.updateRound();
				if (!o.isAlive()) {
					if (o.parent) {
						o.parent.removeChild(o);
					}
					archonsB.splice(i, 1);
					i--;
				}
			}
			
			var heightMatrix:Array = map.getTerrainTileMatrix();
			for (i = 0; i < flux.length; i++) {
				for (j = 0; j < flux[i].length; j++) {
					if (roundNum % heightMatrix[i][j].getHeight() == 0) {
						flux[i][j] = Math.min(64, flux[i][j]+1);
					}
				}
			}
		}
		
		private function processEndOfRound():void {
			// mine flux
			var x:int, y:int, i:int;
			var xOffset:int, yOffset:int, loc:MapLocation;
			for each (var o:DrawRobot in groundRobots) {
				if (o.getType() == RobotType.WOUT) {
					loc = o.getLocation();
					x = loc.getX() - origin.getX();
					y = loc.getY() - origin.getY();
					for (i = fluxMineOffsetsX.length - 1; i >= 0; i--) {
						xOffset = x + fluxMineOffsetsX[i];
						yOffset = y + fluxMineOffsetsY[i];
						if (xOffset < 0 || xOffset >= map.getWidth())
							continue;
						if (yOffset < 0 || yOffset >= map.getHeight())
							continue;
						flux[yOffset][xOffset] = 0;
					}
				}
			}
			
			roundNum++;
		}
		
		///////////////////////////////////////////////////////
		////////////// PRIVATE HELPER FUNCTIONS ///////////////
		///////////////////////////////////////////////////////
		
		private function getRobot(id:uint):DrawRobot {
			if (groundRobots[id]) return groundRobots[id] as DrawRobot;
			if (airRobots[id]) return airRobots[id] as DrawRobot;
			return null;
		}
		
		private function removeRobot(id:uint):void {
			if (groundRobots[id]) delete groundRobots[id];
			if (airRobots[id]) delete airRobots[id];
		}
		
		private function translateCoordinates(loc:MapLocation):MapLocation {
			return new MapLocation(loc.getX() - origin.getX(), loc.getY() - origin.getY());
		}
		
		///////////////////////////////////////////////////////
		/////////////////// SIGNAL HANDLERS ///////////////////
		///////////////////////////////////////////////////////
		
		override public function visitAttackSignal(s:AttackSignal):* {
			getRobot(s.getRobotID()).attack(s.getTargetLoc(), s.getTargetLevel());
		}
		
		override public function visitBroadcastSignal(s:BroadcastSignal):* {
			getRobot(s.getRobotID()).broadcast();
		}
		
		override public function visitConvexHullSignal(s:ConvexHullSignal):* {
			if (s.getTeam() == Team.A)
				convexHullsA = s.getHulls();
			if (s.getTeam() == Team.B)
				convexHullsB = s.getHulls();
		}
		
		override public function visitDeathSignal(s:DeathSignal):* {
			var robot:DrawRobot = getRobot(s.getRobotID());
			
			robot.destroyUnit();
			
			if (robot.getType() == RobotType.ARCHON) {
				var archons:Array = robot.getTeam() == Team.A ? archonsA : archonsB;
				for each (var o:DrawRobot in archons) {
					if (o.getRobotID() == robot.getRobotID()) {
						o.destroyUnit();
						break;
					}
				}
			}
		}
		
		override public function visitEnergonChangeSignal(s:EnergonChangeSignal):* {
			var robotIDs:Array = s.getRobotIDs();
			var energon:Array = s.getEnergon();
			
			for (var i:uint; i < robotIDs.length; i++) {
				var robot:DrawRobot = getRobot(robotIDs[i]);
				robot.setEnergon(energon[i]);
				if (robot.getType() == RobotType.ARCHON) {
					var archons:Array = robot.getTeam() == Team.A ? archonsA : archonsB;
					for each (var o:DrawRobot in archons) {
						if (o.getRobotID() == robot.getRobotID()) {
							o.setEnergon(energon[i]);
							break;
						}
					}
				}
			}
		}
		
		override public function visitEnergonTransferSignal(s:EnergonTransferSignal):* {
			getRobot(s.getRobotID()).transferEnergon(s.getTargetLoc(), s.getTargetLevel(), s.getAmount());
		}
		
		override public function visitEvolutionSignal(s:EvolutionSignal):* {
			getRobot(s.getRobotID()).evolve(s.getType());
		}
		
		override public function visitFluxChangeSignal(s:FluxChangeSignal):* {
			var robotIDs:Array = s.getRobotIDs();
			var flux:Array = s.getFlux();
			
			for (var i:uint; i < robotIDs.length; i++) {
				var robot:DrawRobot = getRobot(robotIDs[i]);
				if (robot && RobotType.isBuilding(robot.getType())) {
					robot.setFlux(flux[i]);
				}
			}
		}
		
		override public function visitFluxTransferSignal(s:FluxTransferSignal):* {
			getRobot(s.getRobotID()).transferFlux(s.getTargetLoc(), s.getTargetLevel(), s.getAmount());
		}
		
		override public function visitIndicatorStringSignal(s:IndicatorStringSignal):* {
			getRobot(s.getRobotID()).setIndicatorString(s.getIndicatorString(), s.getIndex());
		}
		
		override public function visitMineFluxSignal(s:MineFluxSignal):* {
			var locs:Array = s.getLocs();
			for (var i:uint = 0; i < locs.length; i++) {
				for (var j:uint = 0; j < locs[i].length; j++) {
					if (locs[i][j])
						flux[i][j] = 0;
				}
			}
		}
		
		override public function visitMovementSignal(s:MovementSignal):* {
			getRobot(s.getRobotID()).moveToLocation(s.getTargetLoc(), s.isMovingForward());
		}
		
		override public function visitSetAuraSignal(s:SetAuraSignal):* {
			getRobot(s.getRobotID()).setAura(s.getAura());
		}
		
		override public function visitSetDirectionSignal(s:SetDirectionSignal):* {
			var robot:DrawRobot = getRobot(s.getRobotID());
			
			robot.setDirection(s.getDirection());
			
			if (robot.getType() == RobotType.ARCHON) {
				var archons:Array = robot.getTeam() == Team.A ? archonsA : archonsB;
				for each (var o:DrawRobot in archons) {
					if (o.getRobotID() == robot.getRobotID()) {
						o.setDirection(s.getDirection());
						break;
					}
				}
			}
		}
		
		override public function visitSpawnSignal(s:SpawnSignal):* {
			var robot:DrawRobot = new DrawRobot(s.getRobotID(), s.getRobotType(), s.getTeam());
			robot.setLocation(s.getLocation());
			robot.setDirection(s.getDirection());
			if (RobotType.isAirborne(s.getRobotType())) {
				airRobots[s.getRobotID()] = robot;
			} else {
				groundRobots[s.getRobotID()] = robot;
			}
			if (s.getRobotType() == RobotType.ARCHON) {
				if (s.getTeam() == Team.A) archonsA.push(robot.clone());
				if (s.getTeam() == Team.B) archonsB.push(robot.clone());
			}
		}
		
	}
	
}