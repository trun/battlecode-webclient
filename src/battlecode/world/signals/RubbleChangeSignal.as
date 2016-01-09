package battlecode.world.signals {
import battlecode.common.MapLocation;

    public class RubbleChangeSignal implements Signal {
        private var loc:MapLocation;
        private var rubble:Number;

        public function RubbleChangeSignal(loc:MapLocation, rubble:Number) {
            this.loc = loc;
            this.rubble = rubble;
        }

        public function getLocation():MapLocation {
            return loc;
        }

        public function getRubble():Number {
            return rubble;
        }

        public function accept(handler:SignalHandler):* {
            handler.visitRubbleChangeSignal(this);
        }

    }

}