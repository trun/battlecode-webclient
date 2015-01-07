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
        private var hqA:DrawRobot;
        private var hqB:DrawRobot;

        // stats
        private var aPoints:Number;
        private var bPoints:Number;
        private var roundNum:uint;
        private var unitCounts:Object;

        // ore
        private var oreMined:Array; // Number[][]

        // immutables
        private var map:GameMap;
        private var origin:MapLocation;

        public function DrawState(map:GameMap) {
            groundRobots = new Object();

            aPoints = 0;
            bPoints = 0;
            roundNum = 1;

            unitCounts = new Object();
            unitCounts[Team.A] = new Object();
            unitCounts[Team.B] = new Object();
            for each (var type:String in RobotType.values()) {
                unitCounts[Team.A][type] = 0;
                unitCounts[Team.B][type] = 0;
            }

            this.map = map;
            this.origin = map.getOrigin();

            oreMined = [];
            for (var i:int = 0; i < map.getHeight(); i++) {
                oreMined.push(new Array(map.getWidth()));
                for (var j:int = 0; j < map.getWidth(); j++) {
                    oreMined[i][j] = 0;
                }
            }
        }

        ///////////////////////////////////////////////////////
        ///////////////// PROPERTY GETTERS ////////////////////
        ///////////////////////////////////////////////////////

        public function getGroundRobots():Object {
            return groundRobots;
        }

        public function getHQ(team:String):DrawRobot {
            return team == Team.A ? hqA : hqB;
        }

        public function getPoints(team:String):uint {
            return (team == Team.A) ? aPoints : bPoints;
        }

        public function getUnitCount(type:String, team:String):int {
            return unitCounts[team][type];
        }

        public function getOreMined():Array {
            return oreMined;
        }

        ///////////////////////////////////////////////////////
        /////////////////// CORE FUNCTIONS ////////////////////
        ///////////////////////////////////////////////////////

        private function copyStateFrom(state:DrawState):void {
            var a:*, i:int;

            groundRobots = new Object();
            for (a in state.groundRobots) {
                groundRobots[a] = state.groundRobots[a].clone();
            }

            hqA = state.hqA ? state.hqA.clone() as DrawRobot : null;
            hqB = state.hqB ? state.hqB.clone() as DrawRobot : null;

            unitCounts = {};
            unitCounts[Team.A] = {};
            unitCounts[Team.B] = {};
            for (var robotType:String in RobotType.values()) {
                unitCounts[Team.A][robotType] = state.unitCounts[Team.A][robotType];
                unitCounts[Team.B][robotType] = state.unitCounts[Team.B][robotType];
            }

            oreMined = [];
            for (i = 0; i < state.oreMined.length; i++) {
                oreMined.push(state.oreMined[i].concat());
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

            if (hqA) {
                hqA.updateRound();
                if (!hqA.isAlive()) {
                    if (hqA.parent) {
                        hqA.parent.removeChild(hqA);
                    }
                    hqA = null;
                }
            }

            if (hqB) {
                hqB.updateRound();
                if (!hqB.isAlive()) {
                    if (hqB.parent) {
                        hqB.parent.removeChild(hqB);
                    }
                    hqB = null;
                }
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

            if (robot.getType() == RobotType.HQ) {
                var hq:DrawRobot = robot.getTeam() == Team.A ? hqA : hqB;
                hq.destroyUnit();
            }

            unitCounts[robot.getTeam()][robot.getType()]--;
        }

        override public function visitHealthChangeSignal(s:HealthChangeSignal):* {
            var robotIDs:Array = s.getRobotIDs();
            var healths:Array = s.getHealths();

            for (var i:uint; i < robotIDs.length; i++) {
                var robot:DrawRobot = getRobot(robotIDs[i]);
                robot.setEnergon(healths[i]);

                if (robot.getType() == RobotType.HQ) {
                    var hq:DrawRobot = robot.getTeam() == Team.A ? hqA : hqB;
                    hq.setEnergon(healths[i]);
                }
            }
        }

        override public function visitIndicatorStringSignal(s:IndicatorStringSignal):* {
            getRobot(s.getRobotID()).setIndicatorString(s.getIndicatorString(), s.getIndex());
        }

        override public function visitLocationOreChangeSignal(s:LocationOreChangeSignal):* {
            var loc:MapLocation = translateCoordinates(s.getLocation());
            oreMined[loc.getY()][loc.getX()] = s.getOre();
        }

        override public function visitMovementSignal(s:MovementSignal):* {
            getRobot(s.getRobotID()).moveToLocation(s.getTargetLoc());
        }

        override public function visitSpawnSignal(s:SpawnSignal):* {
            var robot:DrawRobot = new DrawRobot(s.getRobotID(), s.getRobotType(), s.getTeam());
            robot.setLocation(s.getLocation());
            robot.spawn(s.getDelay());

            if (s.getRobotType() == RobotType.HQ) {
                if (s.getTeam() == Team.A) hqA = robot.clone() as DrawRobot;
                if (s.getTeam() == Team.B) hqB = robot.clone() as DrawRobot;
            }

            groundRobots[s.getRobotID()] = robot;
            unitCounts[s.getTeam()][s.getRobotType()]++;
        }

        override public function visitTeamOreSignal(s:TeamOreSignal):* {
            aPoints = s.getOre(Team.A);
            bPoints = s.getOre(Team.B);
        }

    }

}