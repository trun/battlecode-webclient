package battlecode.client.viewer.render {
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
        private var zombieRobots:Object;
        private var archonsA:Object; // id -> DrawRobot
        private var archonsB:Object; // id -> DrawRobot

        // stats
        private var aPoints:Number;
        private var bPoints:Number;
        private var roundNum:uint;
        private var unitCounts:Object;

        // rubble
        private var rubble:Array; // Number[][]
        private var parts:Array; // Number[][]

        // immutables
        private var map:GameMap;
        private var origin:MapLocation;

        public function DrawState(map:GameMap) {
            groundRobots = {};
            zombieRobots = {};
            archonsA = {};
            archonsB = {};

            aPoints = 0;
            bPoints = 0;
            roundNum = 1;

            unitCounts = {};
            unitCounts[Team.A] = {};
            unitCounts[Team.B] = {};
            for each (var robotType:String in RobotType.units()) {
                unitCounts[Team.A][robotType] = 0;
                unitCounts[Team.B][robotType] = 0;
            }

            this.map = map;
            this.origin = map.getOrigin();

            var i:int = 0, j:int = 0;

            var initialRubble:Array = map.getInitialRubble();
            rubble = [];
            for (i = 0; i < map.getHeight(); i++) {
                rubble.push(new Array(map.getWidth()));
                for (j = 0; j < map.getWidth(); j++) {
                    rubble[i][j] = initialRubble[i][j];
                }
            }

            var initialParts:Array = map.getInitialParts();
            parts = [];
            for (i = 0; i < map.getHeight(); i++) {
                parts.push(new Array(map.getWidth()));
                for (j = 0; j < map.getWidth(); j++) {
                    parts[i][j] = initialParts[i][j];
                }
            }
        }

        ///////////////////////////////////////////////////////
        ///////////////// PROPERTY GETTERS ////////////////////
        ///////////////////////////////////////////////////////

        public function getGroundRobots():Object {
            return groundRobots;
        }

        public function getZombieRobots():Object {
            return zombieRobots;
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
        
        public function getParts():Array {
            return parts;
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

            zombieRobots = {};
            for (a in state.zombieRobots) {
                zombieRobots[a] = state.zombieRobots[a].clone();
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
            for each (var robotType:String in RobotType.values()) {
                unitCounts[Team.A][robotType] = state.unitCounts[Team.A][robotType];
                unitCounts[Team.B][robotType] = state.unitCounts[Team.B][robotType];
            }

            rubble = [];
            for (i = 0; i < state.rubble.length; i++) {
                rubble.push(state.rubble[i].concat());
            }

            parts = [];
            for (i = 0; i < state.parts.length; i++) {
                parts.push(state.parts[i].concat());
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

            for (a in zombieRobots) {
                o = zombieRobots[a] as DrawRobot;
                o.updateRound();
                if (!o.isAlive()) {
                    if (o.parent) {
                        o.parent.removeChild(o);
                    }
                    delete zombieRobots[a];
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
            if (zombieRobots[id]) return zombieRobots[id] as DrawRobot;
            return null;
        }

        private function removeRobot(id:uint):void {
            if (groundRobots[id]) delete groundRobots[id];
            if (zombieRobots[id]) delete zombieRobots[id];
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

        override public function visitBroadcastSignal(s:BroadcastSignal):* {
            getRobot(s.getRobotID()).broadcast();
        }

        override public function visitDeathSignal(s:DeathSignal):* {
            var robot:DrawRobot = getRobot(s.getRobotID());
            robot.destroyUnit(!s.getDeathByActivation());

            if (robot.getType() == RobotType.ARCHON) {
                var archon:DrawRobot = robot.getTeam() == Team.A
                        ? archonsA[robot.getRobotID()]
                        : archonsB[robot.getRobotID()];
                archon.destroyUnit(!s.getDeathByActivation());
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

        override public function visitInfectionSignal(s:InfectionSignal):* {
            var robotIDs:Array = s.getRobotIDs();
            var zombieTurns:Array = s.getZombieTurns();
            var viperTurns:Array = s.getViperTurns();

            for (var i:uint; i < robotIDs.length; i++) {
                var robot:DrawRobot = getRobot(robotIDs[i]);
                robot.setZombieInfectedTurns(zombieTurns[i]);
                robot.setViperInfectedTurns(viperTurns[i]);

                if (robot.getType() == RobotType.ARCHON) {
                    var archon:DrawRobot = robot.getTeam() == Team.A
                            ? archonsA[robot.getRobotID()]
                            : archonsB[robot.getRobotID()];
                    archon.setZombieInfectedTurns(zombieTurns[i]);
                    archon.setViperInfectedTurns(viperTurns[i]);
                }
            }
        }

        override public function visitIndicatorStringSignal(s:IndicatorStringSignal):* {
            getRobot(s.getRobotID()).setIndicatorString(s.getIndicatorString(), s.getIndex());
        }

        override public function visitRubbleChangeSignal(s:RubbleChangeSignal):* {
            // robots can clear rubble for OOB locations
            if (!map.isOnMap(s.getLocation())) {
                return;
            }
            var loc:MapLocation = translateCoordinates(s.getLocation());
            rubble[loc.getY()][loc.getX()] = s.getRubble();
        }

        override public function visitPartsChangeSignal(s:PartsChangeSignal):* {
            var loc:MapLocation = translateCoordinates(s.getLocation());
            parts[loc.getY()][loc.getX()] = s.getParts();
        }

        override public function visitMovementSignal(s:MovementSignal):* {
            getRobot(s.getRobotID()).moveToLocation(s.getTargetLoc(), s.getDelay());
        }

        override public function visitSpawnSignal(s:SpawnSignal):* {
            var robot:DrawRobot = new DrawRobot(s.getRobotID(), s.getRobotType(), s.getTeam());
            robot.setLocation(s.getLocation());
            robot.spawn(s.getDelay());

            if (s.getRobotType() == RobotType.ARCHON) {
                if (s.getTeam() == Team.A) archonsA[s.getRobotID()] = robot.clone();
                if (s.getTeam() == Team.B) archonsB[s.getRobotID()] = robot.clone();
            }

            if (RobotType.isZombie(s.getRobotType())) {
                zombieRobots[s.getRobotID()] = robot;
            } else {
                groundRobots[s.getRobotID()] = robot;
            }

            if (Team.isPlayer(s.getTeam())) {
                unitCounts[s.getTeam()][s.getRobotType()]++;
            }
        }

        override public function visitTeamResourceSignal(s:TeamResourceSignal):* {
            if (s.getTeam() == Team.A) {
                aPoints = s.getResource();
            } else if (s.getTeam() == Team.B) {
                bPoints = s.getResource();
            }
        }

        override public function visitTypeChangeSignal(s:TypeChangeSignal):* {
            var r:DrawRobot = getRobot(s.getRobotID());

            if (Team.isPlayer(r.getTeam())) {
                unitCounts[r.getTeam()][r.getType()]--;
                unitCounts[r.getTeam()][s.getType()]++;
            }

            r.setType(s.getType());
        }
    }

}