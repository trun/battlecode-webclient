package battlecode.world.signals {
    import battlecode.client.viewer.render.RenderConfiguration;
    import battlecode.common.AttackType;
    import battlecode.common.MapLocation;
    import battlecode.serial.ParseUtils;

    public class SignalFactory {

        public function SignalFactory() {
        }

        public static function createSignal(signalXML:XML):Signal {
            var signalName:String = signalXML.name();
            switch (signalName) {
                case "sig.AttackSignal":
                    return createAttackSignal(signalXML);
                case "sig.BroadcastSignal":
                    return createBroadcastSignal(signalXML);
                case "sig.DeathSignal":
                    return createDeathSignal(signalXML);
                case "sig.IndicatorStringSignal":
                    return createIndicatorStringSignal(signalXML);
                case "sig.RubbleChangeSignal":
                    return createRubbleChangeSignal(signalXML);
                case "sig.PartsChangeSignal":
                    return createPartsChangeSignal(signalXML);
                case "sig.MovementSignal":
                    return createMovementSignal(signalXML);
                case "sig.HealthChangeSignal":
                    return createHealthChangeSignal(signalXML);
                case "sig.InfectionSignal":
                    return createInfectionSignal(signalXML);
                case "sig.SpawnSignal":
                    return createSpawnSignal(signalXML);
                case "sig.TeamResourceSignal":
                    return createTeamResourceSignal(signalXML);
                case "sig.TypeChangeSignal":
                    return createTypeChangeSignal(signalXML);
            }
            return null;
        }

        public static function createAttackSignal(signalXML:XML):AttackSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("targetLoc"));
            var attackType:String = AttackType.fromType(parseInt(signalXML.attribute("attackType")));
            return new AttackSignal(robotID, loc, attackType);
        }

        public static function createBroadcastSignal(signalXML:XML):BroadcastSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            return new BroadcastSignal(robotID);
        }

        public static function createDeathSignal(signalXML:XML):DeathSignal {
            var robotID:uint = parseInt(signalXML.attribute("objectID"));
            var deathByActivation:Boolean = ParseUtils.parseBoolean(signalXML.attribute("deathByActivation"));
            return new DeathSignal(robotID, deathByActivation);
        }

        public static function createMovementSignal(signalXML:XML):MovementSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("newLoc"));
            var type:String = signalXML.child("mt").text();
            var delay:uint = parseInt(signalXML.attribute("delay"));
            return new MovementSignal(robotID, loc, type, delay);
        }

        public static function createHealthChangeSignal(signalXML:XML):HealthChangeSignal {
            var robotIDs:Array = signalXML.attribute("robotIDs").split(",");
            robotIDs = robotIDs.map(function (element:*, index:int, arr:Array):uint {
                return parseInt(element);
            });

            var healths:Array = signalXML.attribute("health").split(",");
            healths = healths.map(function (element:*, index:int, arr:Array):uint {
                return parseFloat(element);
            });

            return new HealthChangeSignal(robotIDs, healths);
        }

        public static function createIndicatorStringSignal(signalXML:XML):IndicatorStringSignal {
            if (RenderConfiguration.isTournament()) {
                return null;
            }
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var index:uint = parseInt(signalXML.attribute("stringIndex"));
            var str:String = ParseUtils.unencode(signalXML.attribute("newString"));
            return new IndicatorStringSignal(robotID, index, str);
        }

        public static function createRubbleChangeSignal(signalXML:XML):RubbleChangeSignal {
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("loc"));
            var amount:Number = parseFloat(signalXML.attribute("amount"));
            return new RubbleChangeSignal(loc, amount);
        }

        public static function createPartsChangeSignal(signalXML:XML):PartsChangeSignal {
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("loc"));
            var amount:Number = parseFloat(signalXML.attribute("amount"));
            return new PartsChangeSignal(loc, amount);
        }

        public static function createSpawnSignal(signalXML:XML):SpawnSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var parentID:uint = parseInt(signalXML.attribute("parentID"));
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("loc"));
            var type:String = signalXML.attribute("type").toString();
            var team:String = signalXML.attribute("team").toString();
            var delay:uint = parseInt(signalXML.attribute("delay"));
            return new SpawnSignal(robotID, parentID, loc, type, team, delay);
        }

        public static function createTeamResourceSignal(signalXML:XML):TeamResourceSignal {
            var team:String = signalXML.attribute("team").toString();
            var resource:Number = parseFloat(signalXML.attribute("resource"));
            return new TeamResourceSignal(team, resource);
        }

        public static function createInfectionSignal(signalXML:XML):InfectionSignal {
            var robotIDs:Array = signalXML.attribute("robotIDs").split(",");
            robotIDs = robotIDs.map(function (element:*, index:int, arr:Array):uint {
                return parseInt(element);
            });

            var zombieTurns:Array = signalXML.attribute("zombieInfectedTurns").split(",");
            zombieTurns = zombieTurns.map(function (element:*, index:int, arr:Array):uint {
                return parseInt(element);
            });

            var viperTurns:Array = signalXML.attribute("viperInfectedTurns").split(",");
            viperTurns = viperTurns.map(function (element:*, index:int, arr:Array):uint {
                return parseInt(element);
            });

            return new InfectionSignal(robotIDs, zombieTurns, viperTurns);
        }

        public static function createTypeChangeSignal(signalXML:XML):TypeChangeSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var type:String = signalXML.attribute("type").toString();
            return new TypeChangeSignal(robotID, type);
        }
     }

}