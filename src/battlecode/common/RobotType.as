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

        public static function values():Array {
            return [ HQ, SOLDIER, MEDBAY, SHIELDS, ARTILLERY, SUPPLIER, GENERATOR, ENCAMPMENT ];
        }

        public static function ground():Array {
            return [ SOLDIER, ARTILLERY, SUPPLIER, GENERATOR, SHIELDS, MEDBAY ];
        }

        public static function maxEnergon(type:String):Number {
            switch (type) {
                case HQ:
                    return 500.0;
                case SOLDIER:
                    return 40.0;
                case MEDBAY:
                    return 100.0;
                case SHIELDS:
                    return 100.0;
                case ARTILLERY:
                    return 100.0;
                case GENERATOR:
                    return 100.0;
                case SUPPLIER:
                    return 100.0;
            }
            return 100;
        }

        public static function movementDelay(type:String):uint {
            return 1;
        }

        public static function movementDelayDiagonal(type:String):uint {
            return 1;
        }

        public static function attackDelay(type:String):uint {
            switch (type) {
                case SOLDIER:
                case MEDBAY:
                case SHIELDS:
                    return 1;
                case ARTILLERY:
                    return 20;
            }
            return 0;
        }

        public static function sensorRadius(type:String):Number {
            switch (type) {
                case SOLDIER:
                    return 14;
            }
            return 14;
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