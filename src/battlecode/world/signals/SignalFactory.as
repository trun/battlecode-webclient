package battlecode.world.signals {
	import battlecode.common.MapLocation;
	import battlecode.serial.ParseUtils;
	
	public class SignalFactory {
		
		public function SignalFactory() { }
		
		public static function createSignal(signalXML:XML):Signal {
			var signalName:String = signalXML.name();
			switch(signalName) {
				case "attackSignal":
					return createAttackSignal(signalXML);
				case "broadcastSignal":
					return createBroadcastSignal(signalXML);
				case "convexHullSignal":
					return createConvexHullSignal(signalXML);
				case "deathSignal":
					return createDeathSignal(signalXML);
				case "deploySignal":
					return createDeploySignal(signalXML);
				case "doTeleportSignal":
					return createDoTeleportSignal(signalXML);
				case "energonChangeSignal":
					return createEnergonChangeSignal(signalXML);
				case "energonTransferSignal":
					return createEnergonTransferSignal(signalXML);
				case "fluxChangeSignal":
					return createFluxChangeSignal(signalXML);
				case "fluxTransferSignal":
					return createFluxTransferSignal(signalXML);
				case "evolutionSignal":
					return createEvolutionSignal(signalXML);
				//case "indicatorStringSignal":
				//	return createIndicatorStringSignal(signalXML);
				//case "mineFluxSignal":
				//	return createMineFluxSignal(signalXML);
				case "movementSignal":
					return createMovementSignal(signalXML);
				case "setAuraSignal":
					return createSetAuraSignal(signalXML);
				case "setDirectionSignal":
					return createSetDirectionSignal(signalXML);
				case "spawnSignal":
					return createSpawnSignal(signalXML);
				case "startTeleportSignal":
					return createStartTeleportSignal(signalXML);
				case "undeploySignal":
					return createUndeploySignal(signalXML);
			}
			return null;
		}
		
		public static function createAttackSignal(signalXML:XML):AttackSignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("loc"));
			var level:String = signalXML.attribute("level").toString();
			return new AttackSignal(robotID, loc, level);
		}
		
		public static function createBroadcastSignal(signalXML:XML):BroadcastSignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			return new BroadcastSignal(robotID);
		}
		
		public static function createConvexHullSignal(signalXML:XML):ConvexHullSignal {
			var team:String = signalXML.attribute("team").toString();
			var hullsXML:XMLList = signalXML.child("hull");
			var hulls:Array = new Array();
			for each (var hullXML:XML in hullsXML) {
				var hullStr:String = hullXML.attribute("locs");
				var hullArr:Array = hullStr.split(";");
				hullArr = hullArr.map(function(item:*, ...rest):* { return ParseUtils.parseLocation(item); } );
				hulls.push(hullArr);
			}
			return new ConvexHullSignal(team, hulls);
		}
		
		public static function createDeathSignal(signalXML:XML):DeathSignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			return new DeathSignal(robotID);
		}
		
		public static function createDeploySignal(signalXML:XML):DeploySignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			return new DeploySignal(robotID);
		}
		
		public static function createDoTeleportSignal(signalXML:XML):DoTeleportSignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			return new DoTeleportSignal(robotID);
		}
		
		public static function createEnergonChangeSignal(signalXML:XML):EnergonChangeSignal {
			var robotIDs:Array = signalXML.attribute("robots").toString().split(",");
			var energon:Array = signalXML.attribute("energon").toString().split(",");
			
			robotIDs = robotIDs.map( function(element:*, index:int, arr:Array):uint { return parseInt(element); } );
			energon = energon.map( function(element:*, index:int, arr:Array):Number { return parseFloat(element); } );
			
			return new EnergonChangeSignal(robotIDs, energon);
		}
		
		public static function createEnergonTransferSignal(signalXML:XML):EnergonTransferSignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("loc"));
			var level:String = signalXML.attribute("level").toString();
			var amount:Number = parseFloat(signalXML.attribute("amt"));
			return new EnergonTransferSignal(robotID, loc, level, amount);
		}
		
		public static function createEvolutionSignal(signalXML:XML):EvolutionSignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			var type:String = signalXML.attribute("type").toString();
			return new EvolutionSignal(robotID, type);
		}
		
		public static function createFluxChangeSignal(signalXML:XML):FluxChangeSignal {
			var robotIDs:Array = signalXML.attribute("robots").toString().split(",");
			var flux:Array = signalXML.attribute("flux").toString().split(",");
			
			robotIDs = robotIDs.map( function(element:*, index:int, arr:Array):uint { return parseInt(element); } );
			flux = flux.map( function(element:*, index:int, arr:Array):Number { return parseFloat(element); } );
			
			return new FluxChangeSignal(robotIDs, flux);
		}
		
		public static function createFluxTransferSignal(signalXML:XML):FluxTransferSignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("loc"));
			var level:String = signalXML.attribute("level").toString();
			var amount:Number = parseFloat(signalXML.attribute("amt"));
			return new FluxTransferSignal(robotID, loc, level, amount);
		}
		
		public static function createIndicatorStringSignal(signalXML:XML):IndicatorStringSignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			var index:uint = parseInt(signalXML.attribute("index"));
			var str:String = ParseUtils.unencode(signalXML.attribute("string"));
			return new IndicatorStringSignal(robotID, index, str);
		}
		
		public static function createMineFluxSignal(signalXML:XML):MineFluxSignal {
			var rowsXML:XMLList = signalXML.child("row");
			var locs:Array = new Array();
			for each (var rowXML:XML in rowsXML) {
				var rowStr:String = rowXML.attribute("locs");
				var rowArr:Array = rowStr.split("");
				trace(rowStr);
				rowArr = rowArr.map(function(item:*, ...rest):* { return item == "1" ? true : false; } );
				locs.push(rowArr);
			}
			return new MineFluxSignal(locs);
		}
		
		public static function createMovementSignal(signalXML:XML):MovementSignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("loc"));
			var forward:Boolean = ParseUtils.parseBoolean(signalXML.attribute("forward"));
			return new MovementSignal(robotID, loc, forward);
		}
		
		public static function createSetAuraSignal(signalXML:XML):SetAuraSignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			var aura:String = signalXML.attribute("aura").toString();
			return new SetAuraSignal(robotID, aura);
		}
		
		public static function createSetDirectionSignal(signalXML:XML):SetDirectionSignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			var dir:String = signalXML.attribute("dir").toString();
			return new SetDirectionSignal(robotID, dir);
		}
		
		public static function createSpawnSignal(signalXML:XML):SpawnSignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			var parentID:uint = parseInt(signalXML.attribute("parent"));
			var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("loc"));
			var type:String = signalXML.attribute("type").toString();
			var team:String = signalXML.attribute("team").toString();
			var dir:String = signalXML.attribute("dir").toString();
			return new SpawnSignal(robotID, parentID, loc, type, team, dir);
		}
		
		public static function createStartTeleportSignal(signalXML:XML):StartTeleportSignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("teleportLoc"));
			var toTeleporterID:uint = parseInt(signalXML.attribute("toTeleporterID"));
			var fromTeleporterID:uint = parseInt(signalXML.attribute("fromTeleporterID"));
			return new StartTeleportSignal(robotID, loc, toTeleporterID, fromTeleporterID);
		}
		
		public static function createUndeploySignal(signalXML:XML):UndeploySignal {
			var robotID:uint = parseInt(signalXML.attribute("robot"));
			return new UndeploySignal(robotID);
		}
		
	}
	
}