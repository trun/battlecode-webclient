package battlecode.client.viewer.render {
    import battlecode.common.MapLocation;
    import battlecode.common.ResearchType;
    import battlecode.common.RobotType;
    import battlecode.common.Team;
    import battlecode.serial.RoundDelta;
    import battlecode.serial.RoundStats;
    import battlecode.world.GameMap;
    import battlecode.world.signals.*;

    public class DrawState extends DefaultSignalHandler {
        // state
        private var mines:Array; // Team[][]
        private var neutralEncampments:Object;
        private var encampments:Object;
        private var groundRobots:Object;
        private var hqA:DrawRobot;
        private var hqB:DrawRobot;

        // stats
        private var aPoints:Number;
        private var bPoints:Number;
        private var aFlux:Number;
        private var bFlux:Number;
        private var aGatheredPoints:Number;
        private var bGatheredPoints:Number;
        private var roundNum:uint;
        private var progressA:Array;
        private var progressB:Array;

        // immutables
        private var map:GameMap;
        private var origin:MapLocation;

        public function DrawState(map:GameMap) {
            neutralEncampments = new Object();
            encampments = new Object();
            groundRobots = new Object();

            mines = new Array();
            for (var i:int = 0; i < map.getWidth(); i++) {
                mines[i] = new Array();
                for (var j:int = 0; j < map.getHeight(); j++) {
                    mines[i][j] = null;
                }
            }

            aPoints = 0;
            bPoints = 0;
            aFlux = 0;
            bFlux = 0;
            aGatheredPoints = 0;
            bGatheredPoints = 0;
            roundNum = 1;

            progressA = [ 0.0, 0.0, 0.0, 0.0, 0.0 ];
            progressB = [ 0.0, 0.0, 0.0, 0.0, 0.0 ];

            this.map = map;
            this.origin = map.getOrigin();
        }

        ///////////////////////////////////////////////////////
        ///////////////// PROPERTY GETTERS ////////////////////
        ///////////////////////////////////////////////////////

        public function getMines():Array {
            return mines;
        }

        public function getNeutralEncampments():Object {
            return neutralEncampments;
        }

        public function getEncampments():Object {
            return encampments
        }

        public function getGroundRobots():Object {
            return groundRobots;
        }

        public function getHQ(team:String):DrawRobot {
            return team == Team.A ? hqA : hqB;
        }

        public function getPoints(team:String):uint {
            return (team == Team.A) ? aPoints : bPoints;
        }

        public function getFlux(team:String):uint {
            return (team == Team.A) ? aFlux : bFlux;
        }

        public function getResearchProgress(team:String):Array {
            return team == Team.A ? progressA : progressB;
        }

        ///////////////////////////////////////////////////////
        /////////////////// CORE FUNCTIONS ////////////////////
        ///////////////////////////////////////////////////////

        private function copyStateFrom(state:DrawState):void {
            var a:*;

            mines = new Array();
            for (var i:int = 0; i < map.getWidth(); i++) {
                mines[i] = new Array();
                for (var j:int = 0; j < map.getHeight(); j++) {
                    mines[i][j] = state.mines[i][j];
                }
            }

            neutralEncampments = new Object();
            for (a in state.neutralEncampments) {
                neutralEncampments[a] = state.neutralEncampments[a].clone();
            }

            encampments = new Object();
            for (a in state.encampments) {
                encampments[a] = state.encampments[a].clone();
            }

            groundRobots = new Object();
            for (a in state.groundRobots) {
                groundRobots[a] = state.groundRobots[a].clone();
            }

            hqA = state.hqA ? state.hqA.clone() as DrawRobot : null;
            hqB = state.hqB ? state.hqB.clone() as DrawRobot : null;

            progressA = state.progressA.concat();
            progressB = state.progressB.concat();

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
            aPoints = stats.getPoints(Team.A);
            bPoints = stats.getPoints(Team.B);
            aGatheredPoints = stats.getGatheredPoints(Team.A);
            bGatheredPoints = stats.getGatheredPoints(Team.B);
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

            for (a in encampments) {
                o = encampments[a] as DrawRobot;
                o.updateRound();
                if (!o.isAlive()) {
                    if (o.parent) {
                        o.parent.removeChild(o);
                    }
                    delete encampments[a];
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
            if (encampments[id]) return encampments[id] as DrawRobot;
            return null;
        }

        private function removeRobot(id:uint):void {
            if (groundRobots[id]) delete groundRobots[id];
            if (encampments[id]) delete encampments[id];
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

            if (RobotType.isEncampment(robot.getType())) {
                var encampment:DrawRobot = new DrawRobot(0, RobotType.ENCAMPMENT, Team.NEUTRAL);
                encampment.setLocation(robot.getLocation());
                neutralEncampments[robot.getLocation()] = encampment;
            }
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
            aFlux = s.getFlux(Team.A);
            bFlux = s.getFlux(Team.B);
        }

        override public function visitIndicatorStringSignal(s:IndicatorStringSignal):* {
            getRobot(s.getRobotID()).setIndicatorString(s.getIndicatorString(), s.getIndex());
        }

        override public function visitMineSignal(s:MineSignal):* {
            var loc:MapLocation = translateCoordinates(s.getLocation());
            if (map.isOnMap(loc)) {
                if (s.isBirth()) {
                    if (!mines[loc.getX()][loc.getY()]) {
                        mines[loc.getX()][loc.getY()] = s.getTeam();
                    }
                } else {
                    mines[loc.getX()][loc.getY()] = null;
                }
            }
        }

        override public function visitMineLayerSignal(s:MineLayerSignal):* {
            var robot:DrawRobot = getRobot(s.getRobotID());
            if (s.isLaying()) {
                robot.layMine();
            } else {
                var researchProgress:Array = robot.getTeam() == Team.A ? progressA : progressB;
                var hasUpgrade:Boolean = researchProgress[ResearchType.getField(ResearchType.PIXAXE)] == 1.0;
                robot.diffuseMine(hasUpgrade);
            }
        }

        override public function visitMovementSignal(s:MovementSignal):* {
            getRobot(s.getRobotID()).moveToLocation(s.getTargetLoc());
        }

        override public function visitNodeBirthSignal(s:NodeBirthSignal):* {
            var encampment:DrawRobot = new DrawRobot(0, RobotType.ENCAMPMENT, Team.NEUTRAL);
            encampment.setLocation(s.getLocation());
            neutralEncampments[s.getLocation()] = encampment;
        }

        override public function visitResearchChangeSignal(s:ResearchChangeSignal):* {
            progressA = s.getProgress(Team.A);
            progressB = s.getProgress(Team.B);
        }

        override public function visitSpawnSignal(s:SpawnSignal):* {
            var robot:DrawRobot = new DrawRobot(s.getRobotID(), s.getRobotType(), s.getTeam());
            robot.setLocation(s.getLocation());
            groundRobots[s.getRobotID()] = robot;

            if (s.getRobotType() == RobotType.HQ) {
                if (s.getTeam() == Team.A) hqA = robot.clone() as DrawRobot;
                if (s.getTeam() == Team.B) hqB = robot.clone() as DrawRobot;
            }

            if (RobotType.isEncampment(s.getRobotType())) {
                var o:DrawRobot = neutralEncampments[s.getLocation()];
                if (o) {
                    if (o.parent) {
                        o.parent.removeChild(o);
                    }
                    delete neutralEncampments[s.getLocation()];
                }
            }
        }

    }

}