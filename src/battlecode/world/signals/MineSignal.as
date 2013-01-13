package battlecode.world.signals {
    import battlecode.common.MapLocation;

    public class MineSignal implements Signal {
        private var loc:MapLocation;
        private var team:String;
        private var birth:Boolean;

        public function MineSignal(loc:MapLocation, team:String, birth:Boolean) {
            this.loc = loc;
            this.team = team;
            this.birth = birth;
        }

        public function getLocation():MapLocation {
            return loc;
        }

        public function getTeam():String {
            return team;
        }

        public function isBirth():Boolean {
            return birth;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitMineSignal(this);
        }
    }

}
