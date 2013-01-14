package battlecode.world.signals {
    import battlecode.common.MapLocation;

    public class NodeBirthSignal implements Signal {
        private var loc:MapLocation;

        public function NodeBirthSignal(loc:MapLocation) {
            this.loc = loc;
        }

        public function getLocation():MapLocation {
            return loc;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitNodeBirthSignal(this);
        }
    }

}
