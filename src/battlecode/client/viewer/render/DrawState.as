﻿package battlecode.client.viewer.render {
    import battlecode.common.MapLocation;
    import battlecode.common.RobotType;
    import battlecode.common.Team;
    import battlecode.serial.RoundDelta;
    import battlecode.serial.RoundStats;
    import battlecode.world.GameMap;
    import battlecode.world.signals.*;

    public class DrawState extends DefaultSignalHandler {
        // state
        private var groundRobots:Object;
        private var archonsA:Object; // id -> DrawRobot
        private var archonsB:Object; // id -> DrawRobot

        // stats
        private var aPoints:Number;
        private var bPoints:Number;
        private var roundNum:uint;
        private var unitCounts:Object;

        // rubble
        private var rubble:Array; // Number[][]

        // immutables
        private var map:GameMap;
        private var origin:MapLocation;

        public function DrawState(map:GameMap) {
            groundRobots = {};
            archonsA = {};
            archonsB = {};

            aPoints = 0;
            bPoints = 0;
            roundNum = 1;

            unitCounts = {};
            unitCounts[Team.A] = {};
            unitCounts[Team.B] = {};
            for each (var robotType:String in RobotType.values()) {
                unitCounts[Team.A][robotType] = 0;
                unitCounts[Team.B][robotType] = 0;
            }

            this.map = map;
            this.origin = map.getOrigin();

            var initialRubble:Array = map.getInitialRubble();
            rubble = [];
            for (var i:int = 0; i < map.getHeight(); i++) {
                rubble.push(new Array(map.getWidth()));
                for (var j:int = 0; j < map.getWidth(); j++) {
                    rubble[i][j] = initialRubble[i][j];
                }
            }
        }

        ///////////////////////////////////////////////////////
        ///////////////// PROPERTY GETTERS ////////////////////
        ///////////////////////////////////////////////////////

        public function getGroundRobots():Object {
            return groundRobots;
        }

        public function getArchons(team:String):Object {
            return team == Team.A ? archonsA : archonsB;
        }

        public function getPoints(team:String):uint {
            return (team == Team.A) ? aPoints : bPoints;
        }

        public function getUnitCount(type:String, team:String):int {
            return unitCounts[team][type];
        }

        public function getRubble():Array {
            return rubble;
        }

        ///////////////////////////////////////////////////////
        /////////////////// CORE FUNCTIONS ////////////////////
        ///////////////////////////////////////////////////////

        private function copyStateFrom(state:DrawState):void {
            var a:*, i:int;

            groundRobots = {};
            for (a in state.groundRobots) {
                groundRobots[a] = state.groundRobots[a].clone();
            }

            archonsA = {};
            for (a in state.archonsA) {
                archonsA[a] = state.archonsA[a].clone();
            }

            archonsB = {};
            for (a in state.archonsB) {
                archonsB[a] = state.archonsB[a].clone();
            }

            unitCounts = {};
            unitCounts[Team.A] = {};
            unitCounts[Team.B] = {};
            for (var robotType:String in RobotType.values()) {
                unitCounts[Team.A][robotType] = state.unitCounts[Team.A][robotType];
                unitCounts[Team.B][robotType] = state.unitCounts[Team.B][robotType];
            }

            rubble = [];
            for (i = 0; i < state.rubble.length; i++) {
                rubble.push(state.rubble[i].concat());
            }

            roundNum = state.roundNum;
        }

        public function clone():DrawState {
            var state:DrawState = new DrawState(map);
            state.copyStateFrom(this);
            return state;
        }

        public function applyDelta(delta:RoundDelta):void {
            updateRound();
            for each (var signal:Signal in delta.getSignals()) {
                applySignal(signal);
            }
            processEndOfRound();
        }

        public function applySignal(signal:Signal):void {
            if (signal != null) signal.accept(this);
        }

        public function applyStats(stats:RoundStats):void {
            // points are applied by the TeamOreSignal this year
        }

        public function updateRound():void {
            var a:*, i:uint, j:uint;
            var o:DrawRobot;

            for (a in groundRobots) {
                o = groundRobots[a] as DrawRobot;
                o.updateRound();
                if (!o.isAlive()) {
                    if (o.parent) {
                        o.parent.removeChild(o);
                    }
                    delete groundRobots[a];
                }
            }

            for (a in archonsA) {
                o = archonsA[a] as DrawRobot;
                o.updateRound();
            }

            for (a in archonsB) {
                o = archonsB[a] as DrawRobot;
                o.updateRound();
            }
        }

        private function processEndOfRound():void {
            roundNum++;
        }

        ///////////////////////////////////////////////////////
        ////////////// PRIVATE HELPER FUNCTIONS ///////////////
        ///////////////////////////////////////////////////////

        private function getRobot(id:uint):DrawRobot {
            if (groundRobots[id]) return groundRobots[id] as DrawRobot;
            return null;
        }

        private function removeRobot(id:uint):void {
            if (groundRobots[id]) delete groundRobots[id];
        }

        private function translateCoordinates(loc:MapLocation):MapLocation {
            return new MapLocation(loc.getX() - origin.getX(), loc.getY() - origin.getY());
        }

        ///////////////////////////////////////////////////////
        /////////////////// SIGNAL HANDLERS ///////////////////
        ///////////////////////////////////////////////////////

        override public function visitAttackSignal(s:AttackSignal):* {
            getRobot(s.getRobotID()).attack(s.getTargetLoc());
        }

        override public function visitBashSignal(s:BashSignal):* {
            getRobot(s.getRobotID()).bash(s.getTargetLoc());
        }

        override public function visitBroadcastSignal(s:BroadcastSignal):* {
            getRobot(s.getRobotID()).broadcast();
        }

        override public function visitDeathSignal(s:DeathSignal):* {
            var robot:DrawRobot = getRobot(s.getRobotID());
            robot.destroyUnit();

            if (robot.getType() == RobotType.ARCHON) {
                var tower:DrawRobot = robot.getTeam() == Team.A
                        ? archonsA[robot.getRobotID()]
                        : archonsB[robot.getRobotID()];
                tower.destroyUnit();
            }

            if (Team.isPlayer(robot.getTeam())) {
                unitCounts[robot.getTeam()][robot.getType()]--;
            }
        }

        override public function visitHealthChangeSignal(s:HealthChangeSignal):* {
            var robotIDs:Array = s.getRobotIDs();
            var healths:Array = s.getHealths();

            for (var i:uint; i < robotIDs.length; i++) {
                var robot:DrawRobot = getRobot(robotIDs[i]);
                robot.setEnergon(healths[i]);

                if (robot.getType() == RobotType.ARCHON) {
                    var archon:DrawRobot = robot.getTeam() == Team.A
                            ? archonsA[robot.getRobotID()]
                            : archonsB[robot.getRobotID()];
                    archon.setEnergon(healths[i]);
                }
            }
        }

        override public function visitIndicatorStringSignal(s:IndicatorStringSignal):* {
            getRobot(s.getRobotID()).setIndicatorString(s.getIndicatorString(), s.getIndex());
        }

        override public function visitRubbleChangeSignal(s:RubbleChangeSignal):* {
            var loc:MapLocation = translateCoordinates(s.getLocation());
            rubble[loc.getY()][loc.getX()] = s.getRubble();
        }

        override public function visitMovementSignal(s:MovementSignal):* {
            getRobot(s.getRobotID()).moveToLocation(s.getTargetLoc());
        }

        override public function visitSpawnSignal(s:SpawnSignal):* {
            var robot:DrawRobot = new DrawRobot(s.getRobotID(), s.getRobotType(), s.getTeam());
            robot.setLocation(s.getLocation());
            robot.spawn(s.getDelay());

            if (s.getRobotType() == RobotType.ARCHON) {
                if (s.getTeam() == Team.A) archonsA[s.getRobotID()] = robot.clone();
                if (s.getTeam() == Team.B) archonsB[s.getRobotID()] = robot.clone();
            }

            groundRobots[s.getRobotID()] = robot;

            if (Team.isPlayer(s.getTeam())) {
                unitCounts[s.getTeam()][s.getRobotType()]++;
            }
        }

        override public function visitTeamOreSignal(s:TeamOreSignal):* {
            aPoints = s.getOre(Team.A);
            bPoints = s.getOre(Team.B);
        }
    }

}