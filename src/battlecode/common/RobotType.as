package battlecode.common {
	
	public class RobotType {
		
		public static const ARCHON:String = "ARCHON";
		public static const CHAINER:String = "CHAINER";
		public static const TURRET:String = "TURRET";
		public static const SOLDIER:String = "SOLDIER";
		public static const WOUT:String = "WOUT";
		public static const AURA:String = "AURA";
		public static const COMM:String = "COMM";
		public static const TELEPORTER:String = "TELEPORTER";
		
		public function RobotType() { }
		
		public static function maxEnergon(type:String):Number {
			switch (type) {
				case ARCHON: return 75.0;
				case CHAINER: return 50.0;
				case TURRET: return 50.0;
				case SOLDIER: return 40.0;
				case WOUT: return 30.0;
				case AURA: return 300.0;
				case COMM: return 500.0;
				case TELEPORTER: return 300.0;
			}
			return 0;
		}
		
		public static function maxFlux(type:String):Number {
			switch (type) {
				case ARCHON: return 10000.0;
				case CHAINER: return 250.0;
				case TURRET: return 250.0;
				case SOLDIER: return 250.0;
				case WOUT: return 5000.0;
				case AURA: return 3000.0;
				case COMM: return 5000.0;
				case TELEPORTER: return 3000.0;
			}
			return 0;
		}
		
		public static function movementDelay(type:String):uint {
			switch (type) {
				case ARCHON: return 6;
				case CHAINER: return 5;
				case TURRET: return 5;
				case SOLDIER: return 4;
				case WOUT: return 3;
			}
			return 0;
		}
			
		public static function movementDelayDiagonal(type:String):uint {
			return movementDelay(type) * Math.SQRT2;
		}
		
		public static function attackDelay(type:String):uint {
			switch (type) {
				case CHAINER: return 5;
				case TURRET: return 1;
				case SOLDIER: return 5;
				case WOUT: return 5;
			}
			return 0;
		}
		
		public static function wakeDelay(type:String):uint {
			switch (type) {
				case ARCHON: return 40;
				case CHAINER: return 40;
				case TURRET: return 40;
				case SOLDIER: return 40;
				case WOUT: return 20;
				case AURA: return 40;
				case COMM: return 40;
				case TELEPORTER: 40;
			}
			return 0;
		}
		
		public static function sensorRadius(type:String):Number {
			switch (type) {
				case ARCHON: return 6;
				case CHAINER: return 3;
				case SOLDIER: return 3;
				case WOUT: return 5;
				case TURRET: return 4;
				case COMM: return 11;
				case TELEPORTER: return 3;
				case AURA: return 4;
			}
			return 0;
		}
		
		public static function isAirborne(type:String):Boolean {
			switch (type) {
				case ARCHON:
					return true;
				default:
					return false;
			}
		}
		
		public static function isBuilding(type:String):Boolean {
			switch (type) {
				case AURA:
				case COMM:
				case TELEPORTER:
					return true;
				default:
					return false;
			}
		}
		
	}
	
}