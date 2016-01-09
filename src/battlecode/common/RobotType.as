﻿package battlecode.common {

    public class RobotType {
        public static const ARCHON:String = "ARCHON";
        public static const SCOUT:String = "SCOUT";
        public static const SOLDIER:String = "SOLDIER";
        public static const GUARD:String = "GUARD";
        public static const VIPER:String = "VIPER";
        public static const TURRET:String = "TURRET";
        public static const TTM:String = "TTM";

        public static const ZOMBIEDEN:String = "ZOMBIEDEN";
        public static const STANDARDZOMBIE:String = "STANDARDZOMBIE";
        public static const FASTZOMBIE:String = "FASTZOMBIE";
        public static const RANGEDZOMBIE:String = "RANGEDZOMBIE";
        public static const BIGZOMBIE:String = "BIGZOMBIE";

        public function RobotType() {
        }

        public static function values():Array {
            return [
                ARCHON,
                SCOUT,
                SOLDIER,
                GUARD,
                VIPER,
                TURRET,
                TTM,
                ZOMBIEDEN,
                STANDARDZOMBIE,
                FASTZOMBIE,
                RANGEDZOMBIE,
                BIGZOMBIE
            ];
        }

        public static function units():Array {
            return [
                ARCHON,
                SOLDIER,
                GUARD,
                VIPER,
                TURRET,
                TTM
            ];
        }

        public static function zombies():Array {
            return [
                ZOMBIEDEN,
                STANDARDZOMBIE,
                FASTZOMBIE,
                RANGEDZOMBIE,
                BIGZOMBIE
            ]
        }

        public static function maxEnergon(type:String):Number {
            switch (type) {
                case ARCHON:
                    return 1000;
                case SCOUT:
                    return 100;
                case SOLDIER:
                    return 60;
                case GUARD:
                    return 150;
                case VIPER:
                    return 120;
                case TURRET:
                    return 100;
                case TTM:
                    return 100;
                case ZOMBIEDEN:
                    return 2000;
                case STANDARDZOMBIE:
                    return 60;
                case RANGEDZOMBIE:
                    return 60;
                case FASTZOMBIE:
                    return 80;
                case BIGZOMBIE:
                    return 500;
            }
            throw new ArgumentError("Unknown type: " + type);
        }

        // TODO these should be truncated for animation delays (but not diagonal calcs)
        public static function movementDelay(type:String):Number {
            switch (type) {
                case ARCHON:
                    return 2;
                case SCOUT:
                    return 1.4;
                case SOLDIER:
                    return 2;
                case GUARD:
                    return 2;
                case VIPER:
                    return 2;
                case TURRET:
                    return 0;
                case TTM:
                    return 2;
                case STANDARDZOMBIE:
                    return 3;
                case RANGEDZOMBIE:
                    return 3;
                case FASTZOMBIE:
                    return 1.4;
                case BIGZOMBIE:
                    return 3;
            }
            return 1;
        }

        public static function movementDelayDiagonal(type:String):uint {
            return movementDelay(type) * Math.SQRT2;
        }

        public static function attackDelay(type:String):Number {
            switch (type) {
                case ARCHON:
                    return 2;
                case SCOUT:
                    return 1;
                case SOLDIER:
                    return 2;
                case GUARD:
                    return 2;
                case VIPER:
                    return 2;
                case TURRET:
                    return 0;
                case TTM:
                    return 2;
                case STANDARDZOMBIE:
                    return 2;
                case RANGEDZOMBIE:
                    return 1;
                case FASTZOMBIE:
                    return 1;
                case BIGZOMBIE:
                    return 3;
            }
            return 0;
        }
    }
}