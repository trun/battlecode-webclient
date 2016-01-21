package battlecode.common {

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

        private static var constantsByRobotType:Object = {
            ARCHON: {
                maxHealth: 1000,
                partCost: 0,
                attackDelay: 2,
                isZombie: false
            },
            SCOUT: {
                maxHealth: 80,
                partCost: 25,
                attackDelay: 1,
                isZombie: false
            },
            SOLDIER: {
                maxHealth: 60,
                partCost: 30,
                attackDelay: 2,
                isZombie: false
            },
            GUARD: {
                maxHealth: 145,
                partCost: 30,
                attackDelay: 2,
                isZombie: false
            },
            VIPER: {
                maxHealth: 120,
                partCost: 120,
                attackDelay: 2,
                isZombie: false
            },
            TURRET: {
                maxHealth: 100,
                partCost: 130,
                attackDelay: 2,
                isZombie: false
            },
            TTM: {
                maxHealth: 100,
                partCost: 130,
                attackDelay: 0,
                isZombie: false
            },
            ZOMBIEDEN: {
                maxHealth: 2000,
                partCost: 0,
                attackDelay: 0,
                isZombie: true
            },
            STANDARDZOMBIE: {
                maxHealth: 60,
                partCost: 0,
                attackDelay: 2,
                isZombie: true
            },
            RANGEDZOMBIE: {
                maxHealth: 60,
                partCost: 0,
                attackDelay: 1,
                isZombie: true
            },
            FASTZOMBIE: {
                maxHealth: 80,
                partCost: 0,
                attackDelay: 1,
                isZombie: true
            },
            BIGZOMBIE: {
                maxHealth: 500,
                partCost: 0,
                attackDelay: 3,
                isZombie: true
            }
        };

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
                SOLDIER,
                GUARD,
                VIPER,
                SCOUT,
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

        public static function maxEnergon(robotType:String):Number {
            return constantsByRobotType[robotType]['maxHealth'];
        }

        public static function attackDelay(robotType:String):Number {
            return constantsByRobotType[robotType]['attackDelay'];
        }

        public static function partValue(robotType:String):Number {
            return constantsByRobotType[robotType]['partCost'];
        }

        public static function isZombie(robotType:String):Boolean {
            return constantsByRobotType[robotType]['isZombie'];
        }

        public static function setValues(robotType:String, constants:Object):void {
            constantsByRobotType[robotType] = constants;
        }
    }
}