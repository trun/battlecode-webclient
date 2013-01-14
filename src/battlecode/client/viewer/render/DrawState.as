package battlecode.client.viewer.render {
    import battlecode.common.MapLocation;
    import battlecode.common.Team;
    import battlecode.serial.RoundDelta;
    import battlecode.serial.RoundStats;
    import battlecode.world.GameMap;
    import battlecode.world.signals.*;

    public class DrawState extends DefaultSignalHandler {
        // state
        private var mines:Array; // Team[][]
        private var encampments:Object;
        private var groundRobots:Object;

        // stats
        private var aPoints:Number;
        private var bPoints:Number;
        private var aGatheredPoints:Number;
        private var bGatheredPoints:Number;
        private var roundNum:uint;

        // immutables
        private var map:GameMap;
        private var origin:MapLocation;

        public function DrawState(map:GameMap) {
            groundRobots = new Object();
            encampments = new Object();

            mines = new Array();
            for (var i:int = 0; i < map.getWidth(); i++) {
                mines[i] = new Array();
                for (var j:int = 0; j < map.getHeight(); j++) {
                    mines[i][j] = null;
                }
            }

            aPoints = 0;
            bPoints = 0;
            aGatheredPoints = 0;
            bGatheredPoints = 0;
            roundNum = 1;

            this.map = map;
            this.origin = map.getOrigin();
        }

        ///////////////////////////////////////////////////////
        ///////////////// PROPERTY GETTERS ////////////////////
        ///////////////////////////////////////////////////////

        public function getMines():Array {
            return mines
        }

        public function getEncampments():Object {
            return encampments
        }

        public function getGroundRobots():Object {
            return groundRobots;
        }

        public function getPoints(team:String):uint {
            return (team == Team.A) ? aPoints : bPoints;
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

            encampments = new Object();
            for (a in state.encampments) {
                encampments[a] = state.encampments[a].clone();
            }

            groundRobots = new Object();
            for (a in state.groundRobots) {
                groundRobots[a] = state.groundRobots[a].clone();
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

        override public function visitDeathSignal(s:DeathSignal):* {
            var robot:DrawRobot = getRobot(s.getRobotID());
            robot.destroyUnit();
        }

        override public function visitEnergonChangeSignal(s:EnergonChangeSignal):* {

        }

        override public function visitFluxChangeSignal(s:FluxChangeSignal):* {

        }

        override public function visitIndicatorStringSignal(s:IndicatorStringSignal):* {
            getRobot(s.getRobotID()).setIndicatorString(s.getIndicatorString(), s.getIndex());
        }

        override public function visitMineSignal(s:MineSignal):* {
            var loc:MapLocation = translateCoordinates(s.getLocation());
            if (s.isBirth()) {
                mines[loc.getX()][loc.getY()] = s.getTeam();
            } else {
                mines[loc.getX()][loc.getY()] = null;
            }
        }

        override public function visitMovementSignal(s:MovementSignal):* {
            getRobot(s.getRobotID()).moveToLocation(s.getTargetLoc());
        }

        override public function visitSpawnSignal(s:SpawnSignal):* {
            var robot:DrawRobot = new DrawRobot(s.getRobotID(), s.getRobotType(), s.getTeam());
            robot.setLocation(s.getLocation());
            groundRobots[s.getRobotID()] = robot;
        }

    }

}