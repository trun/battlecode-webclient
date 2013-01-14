package battlecode.world.signals {
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
                case "sig.CaptureSignal":
                    return createCaptureSignal(signalXML);
                case "sig.DeathSignal":
                    return createDeathSignal(signalXML);
                case "sig.EnergonChangeSignal":
                    return createEnergonChangeSignal(signalXML);
                case "sig.FluxChangeSignal":
                    return createFluxChangeSignal(signalXML);
                //case "sig.IndicatorStringSignal":
                //    return createIndicatorStringSignal(signalXML);
                case "sig.MineSignal":
                    return createMineSignal(signalXML);
                case "sig.MinelayerSignal":
                    return createMineLayerSignal(signalXML);
                case "sig.MovementSignal":
                    return createMovementSignal(signalXML);
                case "sig.NodeBirthSignal":
                    return createNodeBirthSignal(signalXML);
                case "sig.ResearchChangeSignal":
                    return createResearchChangeSignal(signalXML);
                case "sig.ShieldChangeSignal":
                    return createShieldChangeSignal(signalXML);
                case "sig.SpawnSignal":
                    return createSpawnSignal(signalXML);
            }
            return null;
        }

        public static function createAttackSignal(signalXML:XML):AttackSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("targetLoc"));
            return new AttackSignal(robotID, loc);
        }

        public static function createBroadcastSignal(signalXML:XML):BroadcastSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            return new BroadcastSignal(robotID);
        }

        public static function createCaptureSignal(signalXML:XML):CaptureSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var parentID:uint = parseInt(signalXML.attribute("parentID"));
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("loc"));
            var type:String = signalXML.attribute("type").toString();
            var team:String = signalXML.attribute("team").toString();
            var handling:Boolean = ParseUtils.parseBoolean(signalXML.attribute("hasHandling"));
            return new CaptureSignal(robotID, parentID, loc, type, team, handling);
        }

        public static function createDeathSignal(signalXML:XML):DeathSignal {
            var robotID:uint = parseInt(signalXML.attribute("objectID"));
            return new DeathSignal(robotID);
        }

        public static function createEnergonChangeSignal(signalXML:XML):EnergonChangeSignal {
            var robotIDs:Array = signalXML.attribute("robotIDs").toString().split(",");
            var energon:Array = signalXML.attribute("energon").toString().split(",");

            robotIDs = robotIDs.map(function (element:*, index:int, arr:Array):uint {
                return parseInt(element);
            });
            energon = energon.map(function (element:*, index:int, arr:Array):Number {
                return parseFloat(element);
            });

            return new EnergonChangeSignal(robotIDs, energon);
        }

        public static function createFluxChangeSignal(signalXML:XML):FluxChangeSignal {
            var flux:Array = signalXML.attribute("flux").toString().split(",");
            var fluxA:Number = parseFloat(flux[0]);
            var fluxB:Number = parseFloat(flux[1]);
            return new FluxChangeSignal(fluxA, fluxB);
        }

        public static function createMineSignal(signalXML:XML):MineSignal {
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("mineLoc"));
            var team:String = signalXML.attribute("mineTeam").toString();
            var birth:Boolean = ParseUtils.parseBoolean(signalXML.attribute("birth"));
            return new MineSignal(loc, team, birth);
        }

        public static function createMineLayerSignal(signalXML:XML):MineLayerSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var laying:Boolean = ParseUtils.parseBoolean(signalXML.attribute("isLaying"));
            return new MineLayerSignal(robotID, laying);
        }

        public static function createMovementSignal(signalXML:XML):MovementSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("newLoc"));
            return new MovementSignal(robotID, loc);
        }

        public static function createNodeBirthSignal(signalXML:XML):NodeBirthSignal {
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("loc"));
            return new NodeBirthSignal(loc);
        }

        public static function createResearchChangeSignal(signalXML:XML):ResearchChangeSignal {
            var progress:XMLList = signalXML.child("progress").children();
            var progressA:Array = progress[0].split(",").map(function (element:*, index:int, arr:Array):Number {
                return parseFloat(element);
            });
            var progressB:Array = progress[1].split(",").map(function (element:*, index:int, arr:Array):Number {
                return parseFloat(element);
            });
            return new ResearchChangeSignal(progressA, progressB);
        }

        public static function createIndicatorStringSignal(signalXML:XML):IndicatorStringSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var index:uint = parseInt(signalXML.attribute("stringIndex"));
            var str:String = ParseUtils.unencode(signalXML.attribute("newString"));
            return new IndicatorStringSignal(robotID, index, str);
        }

        public static function createShieldChangeSignal(signalXML:XML):ShieldChangeSignal {
            var robotIDs:Array = signalXML.attribute("robotIDs").split(",");
            robotIDs = robotIDs.map(function (element:*, index:int, arr:Array):uint {
                return parseInt(element);
            });
            var shields:Array = signalXML.attribute("shield").split(",");
            shields = shields.map(function (element:*, index:int, arr:Array):uint {
                return parseFloat(element);
            });
            return new ShieldChangeSignal(robotIDs, shields);
        }

        public static function createSpawnSignal(signalXML:XML):SpawnSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var parentID:uint = parseInt(signalXML.attribute("parentID"));
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("loc"));
            var type:String = signalXML.attribute("type").toString();
            var team:String = signalXML.attribute("team").toString();
            return new SpawnSignal(robotID, parentID, loc, type, team);
        }
    }

}