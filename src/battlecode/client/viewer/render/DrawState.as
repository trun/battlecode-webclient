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

        ///////////////////////////////////////////////////////
        /////////////////// CORE FUNCTIONS ////////////////////
        ///////////////////////////////////////////////////////

        private function copyStateFrom(state:DrawState):void {
            var a:*;

            groundRobots = new Object();
            for (a in state.groundRobots) {
                groundRobots[a] = state.groundRobots[a].clone();
            }

            hqA = state.hqA ? state.hqA.clone() as DrawRobot : null;
            hqB = state.hqB ? state.hqB.clone() as DrawRobot : null;

            unitCounts = new Object();
            unitCounts[Team.A] = new Object();
            unitCounts[Team.B] = new Object();
            for (a in state.unitCounts[Team.A]) {
                unitCounts[Team.A][a] = state.unitCounts[Team.A][a];
                unitCounts[Team.B][a] = state.unitCounts[Team.B][a];
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
            // points are applied by the FluxChangeSignal this year
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

        override public function visitBroadcastSignal(s:BroadcastSignal):* {
            getRobot(s.getRobotID()).broadcast();
        }

        override public function visitCaptureSignal(s:CaptureSignal):* {
            var robot:DrawRobot = getRobot(s.getParentID());
            robot.capture();
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

        override public function visitEnergonChangeSignal(s:EnergonChangeSignal):* {
            var robotIDs:Array = s.getRobotIDs();
            var energon:Array = s.getEnergon();

            for (var i:uint; i < robotIDs.length; i++) {
                var robot:DrawRobot = getRobot(robotIDs[i]);
                robot.setEnergon(energon[i]);

                if (robot.getType() == RobotType.HQ) {
                    var hq:DrawRobot = robot.getTeam() == Team.A ? hqA : hqB;
                    hq.setEnergon(energon[i]);
                }
            }
        }

        override public function visitFluxChangeSignal(s:FluxChangeSignal):* {
            aPoints = s.getFlux(Team.A);
            bPoints = s.getFlux(Team.B);
        }


        override public function visitIndicatorStringSignal(s:IndicatorStringSignal):* {
            getRobot(s.getRobotID()).setIndicatorString(s.getIndicatorString(), s.getIndex());
        }

        override public function visitMovementSignal(s:MovementSignal):* {
            getRobot(s.getRobotID()).moveToLocation(s.getTargetLoc());
        }

        override public function visitSpawnSignal(s:SpawnSignal):* {
            var robot:DrawRobot = new DrawRobot(s.getRobotID(), s.getRobotType(), s.getTeam());
            robot.setLocation(s.getLocation());

            if (s.getRobotType() == RobotType.HQ) {
                if (s.getTeam() == Team.A) hqA = robot.clone() as DrawRobot;
                if (s.getTeam() == Team.B) hqB = robot.clone() as DrawRobot;
            }

            groundRobots[s.getRobotID()] = robot;
            unitCounts[s.getTeam()][s.getRobotType()]++;
        }

        override public function visitNeutralsDensitySignal(s:NeutralsDensitySignal):* {

        }

        override public function visitNeutralsTeamSignal(s:NeutralsTeamSignal):* {

        }

    }

}