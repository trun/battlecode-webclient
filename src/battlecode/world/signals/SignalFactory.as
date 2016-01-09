﻿package battlecode.world.signals {
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
                case "sig.BashSignal":
                    return createBashSignal(signalXML);
                case "sig.BroadcastSignal":
                    return createBroadcastSignal(signalXML);
                case "sig.DeathSignal":
                    return createDeathSignal(signalXML);
                case "sig.IndicatorStringSignal":
                    return createIndicatorStringSignal(signalXML);
                case "sig.RubbleChangeSignal":
                    return createRubbleChangeSignal(signalXML);
                case "sig.MovementSignal":
                    return createMovementSignal(signalXML);
                case "sig.HealthChangeSignal":
                    return createHealthChangeSignal(signalXML);
                case "sig.SpawnSignal":
                    return createSpawnSignal(signalXML);
                case "sig.TeamOreSignal":
                    return createTeamOreSignal(signalXML);
            }
            return null;
        }

        public static function createAttackSignal(signalXML:XML):AttackSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("targetLoc"));
            var attackType:String = AttackType.fromType(parseInt(signalXML.attribute("attackType")));
            return new AttackSignal(robotID, loc, attackType);
        }

        public static function createBashSignal(signalXML:XML):BashSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("targetLoc"));
            return new BashSignal(robotID, loc);
        }

        public static function createBroadcastSignal(signalXML:XML):BroadcastSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            return new BroadcastSignal(robotID);
        }

        public static function createDeathSignal(signalXML:XML):DeathSignal {
            var robotID:uint = parseInt(signalXML.attribute("objectID"));
            return new DeathSignal(robotID);
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

        public static function createSpawnSignal(signalXML:XML):SpawnSignal {
            var robotID:uint = parseInt(signalXML.attribute("robotID"));
            var parentID:uint = parseInt(signalXML.attribute("parentID"));
            var loc:MapLocation = ParseUtils.parseLocation(signalXML.attribute("loc"));
            var type:String = signalXML.attribute("type").toString();
            var team:String = signalXML.attribute("team").toString();
            var delay:uint = parseInt(signalXML.attribute("delay"));
            return new SpawnSignal(robotID, parentID, loc, type, team, delay);
        }

        public static function createTeamOreSignal(signalXML:XML):TeamOreSignal {
            var ore:Array = signalXML.attribute("ore").split(",");
            ore = ore.map(function (element:*, index:int, arr:Array):uint {
                return parseFloat(element);
            });
            return new TeamOreSignal(ore[0], ore[1]);
        }
    }

}