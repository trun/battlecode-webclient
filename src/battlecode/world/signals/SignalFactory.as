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
                case "sig.CaptureSignal":
                    return createCaptureSignal(signalXML);
                case "sig.DeathSignal":
                    return createDeathSignal(signalXML);
                case "sig.EnergonChangeSignal":
                    return createEnergonChangeSignal(signalXML);
                case "sig.FluxChangeSignal":
                    return createFluxChangeSignal(signalXML);
                case "sig.IndicatorStringSignal":
                    return createIndicatorStringSignal(signalXML);
                case "sig.MovementSignal":
                    return createMovementSignal(signalXML);
                case "sig.NeutralsDensitySignal":
                    return createNeutralsDensitySignal(signalXML);
                case "sig.NeutralsTeamSignal":
                    return createNeutralsTeamSignal(signalXML);
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
            var attackType:String = AttackType.fromType(parseInt(signalXML.attribute("attackType")));
            return new AttackSignal(robotID, loc, attackType);
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

            if (robotIDs.length == 0 || robotIDs[0].length == 0) {
                return null;
            }

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

        public static function createMovementSignal(signalXML:XML):MovementSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("newLoc"));
            var type:String = signalXML.child("mt").text();
            var delay:uint = parseInt(signalXML.attribute("delay"));
            return new MovementSignal(robotID, loc, type, delay);
        }

        public static function createNeutralsDensitySignal(signalXML:XML):NeutralsDensitySignal {
            var amounts:Array = [];
            for each (var row:XML in signalXML.child("amounts").children()) {
                amounts.push(row.text().map(function (element:*, index:int, arr:Array):uint {
                    return parseInt(element);
                }))
            }
            return new NeutralsDensitySignal(amounts);
        }

        public static function createNeutralsTeamSignal(signalXML:XML):NeutralsTeamSignal {
            var teams:Array = [];
            for each (var row:XML in signalXML.child("teams").children()) {
                teams.push(row.text().map(function (element:*, index:int, arr:Array):uint {
                    return parseInt(element);
                }))
            }
            return new NeutralsTeamSignal(teams);
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