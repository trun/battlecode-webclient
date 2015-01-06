package battlecode.common {

    public class RobotType {
        public static const HQ:String = "HQ";
        public static const TOWER:String = "TOWER";

        public static const SUPPLYDEPOT:String = "SUPPLYDEPOT";
        public static const TECHNOLOGYINSTITUTE:String = "TECHNOLOGYINSTITUTE";
        public static const BARRACKS:String = "BARRACKS";
        public static const HELIPAD:String = "HELIPAD";
        public static const TRAININGFIELD:String = "TRAININGFIELD";
        public static const TANKFACTORY:String = "TANKFACTORY";
        public static const HANDWASHSTATION:String = "HANDWASHSTATION";
        public static const AEROSPACELAB:String = "AEROSPACELAB";

        public static const BEAVER:String = "BEAVER";
        public static const COMPUTER:String = "COMPUTER";
        public static const SOLDIER:String = "SOLDIER";
        public static const BASHER:String = "BASHER";
        public static const MINER:String = "MINER";
        public static const DRONE:String = "DRONE";
        public static const TANK:String = "TANK";
        public static const COMMANDER:String = "COMMANDER";
        public static const LAUNCHER:String = "LAUNCHER";
        public static const MISSLE:String = "MISSLE";

        public function RobotType() {
        }

        public static function values():Array {
            return [
                HQ,
                TOWER,
                SUPPLYDEPOT,
                TECHNOLOGYINSTITUTE,
                BARRACKS,
                HELIPAD,
                TRAININGFIELD,
                TANKFACTORY,
                HANDWASHSTATION,
                AEROSPACELAB,
                BEAVER,
                COMPUTER,
                SOLDIER,
                BASHER,
                MINER,
                DRONE,
                TANK,
                COMMANDER,
                LAUNCHER,
                MISSLE
            ];
        }

        public static function buildings():Array {
            return [
                HQ,
                TOWER,
                SUPPLYDEPOT,
                TECHNOLOGYINSTITUTE,
                BARRACKS,
                HELIPAD,
                TRAININGFIELD,
                TANKFACTORY,
                HANDWASHSTATION,
                AEROSPACELAB
            ];
        }

        public static function ground():Array {
            return [
                BEAVER,
                COMPUTER,
                SOLDIER,
                BASHER,
                MINER,
                TANK,
                COMMANDER,
                LAUNCHER,
                MISSLE
            ];
        }

        public static function air():Array {
            return []; // TODO air types
        }

        // TODO fix values
        public static function maxEnergon(type:String):Number {
            switch (type) {
                case HQ:
                    return int.MAX_VALUE;
                case SOLDIER:
                    return 100.0;
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