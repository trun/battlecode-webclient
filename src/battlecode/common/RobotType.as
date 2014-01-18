package battlecode.common {

    public class RobotType {
        public static const HQ:String = "HQ";
        public static const SOLDIER:String = "SOLDIER";
        public static const PASTR:String = "PASTR";
        public static const NOISETOWER:String = "NOISETOWER";

        public function RobotType() {
        }

        public static function values():Array {
            return [ HQ, SOLDIER, PASTR,  NOISETOWER ];
        }

        public static function ground():Array {
            return [ SOLDIER, SOLDIER, PASTR, NOISETOWER ];
        }

        public static function maxEnergon(type:String):Number {
            switch (type) {
                case HQ:
                    return Number.MAX_VALUE;
                case SOLDIER:
                    return 100.0;
                case PASTR:
                    return 100.0;
                case NOISETOWER:
                    return 200.0;
            }
            throw new ArgumentError("Unknown type: " + type);
        }

        public static function movementDelay(type:String):uint {
            return 1;
        }

        public static function movementDelayDiagonal(type:String):uint {
            return 1;
        }

        public static function attackDelay(type:String):uint {
            return 0;
        }
    }
}