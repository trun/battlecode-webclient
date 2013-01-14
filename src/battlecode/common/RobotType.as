package battlecode.common {

    public class RobotType {
        public static const HQ:String = "HQ";
        public static const SOLDIER:String = "SOLDIER";
        public static const MEDBAY:String = "MEDBAY";
        public static const SHIELDS:String = "SHIELDS";
        public static const ARTILLERY:String = "ARTILLERY";
        public static const GENERATOR:String = "GENERATOR";
        public static const SUPPLIER:String = "SUPPLIER";
        public static const ENCAMPMENT:String = "ENCAMPMENT";

        public function RobotType() {
        }

        public static function maxEnergon(type:String):Number {
            switch (type) {
                case HQ:
                    return 75.0;
                case SOLDIER:
                    return 40.0;
                case MEDBAY:
                    return 30.0;
                case SHIELDS:
                    return 300.0;
                case ARTILLERY:
                    return 500.0;
                case GENERATOR:
                    return 300.0;
                case SUPPLIER:
                    return 300.0;
            }
            return 1;
        }

        public static function maxFlux(type:String):Number {
            switch (type) {
                case HQ:
                    return 75.0;
                case SOLDIER:
                    return 40.0;
                case MEDBAY:
                    return 30.0;
                case SHIELDS:
                    return 300.0;
                case ARTILLERY:
                    return 500.0;
                case GENERATOR:
                    return 300.0;
                case SUPPLIER:
                    return 300.0;
            }
            return 1;
        }

        public static function movementDelay(type:String):uint {
            return 1;
        }

        public static function movementDelayDiagonal(type:String):uint {
            return movementDelay(type) * Math.SQRT2;
        }

        public static function attackDelay(type:String):uint {
            switch (type) {
                case SOLDIER:
                    return 5;
            }
            return 0;
        }

        public static function wakeDelay(type:String):uint {
            switch (type) {
                case SOLDIER:
                    return 40;
            }
            return 0;
        }

        public static function sensorRadius(type:String):Number {
            switch (type) {
                case SOLDIER:
                    return 14;
            }
            return 0;
        }

        public static function isEncampment(type:String):Boolean {
            switch (type) {
                case HQ:
                case SOLDIER:
                    return false;
                default:
                    return true;
            }
        }

    }

}