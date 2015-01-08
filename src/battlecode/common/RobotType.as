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
        public static const MINERFACTORY:String = "MINERFACTORY";
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
        public static const MISSILE:String = "MISSILE";

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
                MINERFACTORY,
                AEROSPACELAB,
                HANDWASHSTATION,
                BEAVER,
                COMPUTER,
                SOLDIER,
                BASHER,
                MINER,
                DRONE,
                TANK,
                COMMANDER,
                LAUNCHER,
                MISSILE
            ];
        }

        public static function buildings():Array {
            return [
                SUPPLYDEPOT,
                TECHNOLOGYINSTITUTE,
                BARRACKS,
                HELIPAD,
                TRAININGFIELD,
                TANKFACTORY,
                MINERFACTORY,
                AEROSPACELAB,
                HANDWASHSTATION
            ];
        }

        public static function ground():Array {
            return [
                SOLDIER,
                BASHER,
                COMMANDER,
                TANK,
                LAUNCHER,
                BEAVER,
                MINER,
                COMPUTER
            ];
        }

        public static function units():Array {
            return [
                SOLDIER,
                BASHER,
                COMMANDER,
                TANK,
                LAUNCHER,
                MISSILE,
                BEAVER,
                MINER,
                COMPUTER,
                DRONE
            ];
        }

        public static function air():Array {
            return []; // TODO air types
        }

        public static function maxEnergon(type:String):Number {
            switch (type) {
                case HQ:
                    return 2000;
                case TOWER:
                    return 1000;
                case SUPPLYDEPOT:
                case TECHNOLOGYINSTITUTE:
                case BARRACKS:
                case HELIPAD:
                case TRAININGFIELD:
                case TANKFACTORY:
                case MINERFACTORY:
                case HANDWASHSTATION:
                case AEROSPACELAB:
                    return 100;
                case BEAVER:
                    return 30;
                case MINER:
                    return 50;
                case COMPUTER:
                    return 1;
                case SOLDIER:
                    return 40;
                case BASHER:
                    return 50;
                case DRONE:
                    return 70;
                case TANK:
                    return 160;
                case COMMANDER:
                    return 120;
                case LAUNCHER:
                    return 400;
                case MISSILE:
                    return 3;
            }
            throw new ArgumentError("Unknown type: " + type);
        }

        public static function movementDelay(type:String):uint {
            switch (type) {
                case BEAVER:
                    return 2;
                case MINER:
                    return 2;
                case COMPUTER:
                    return 8;
                case SOLDIER:
                    return 2;
                case BASHER:
                    return 2;
                case DRONE:
                    return 1;
                case TANK:
                    return 2;
                case COMMANDER:
                    return 2;
                case LAUNCHER:
                    return 4;
                case MISSILE:
                    return 1;
            }
            return 1;
        }

        public static function movementDelayDiagonal(type:String):uint {
            return movementDelay(type) * Math.SQRT2;
        }

        public static function attackDelay(type:String):uint {
            switch (type) {
                case BEAVER:
                    return 2;
                case MINER:
                    return 2;
                case COMPUTER:
                    return 0;
                case SOLDIER:
                    return 2;
                case BASHER:
                    return 1;
                case DRONE:
                    return 3;
                case TANK:
                    return 3;
                case COMMANDER:
                    return 1;
                case LAUNCHER:
                    return 0;
                case MISSILE:
                    return 0;
            }
            return 0;
        }
    }
}