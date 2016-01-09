package battlecode.world.signals {
import battlecode.common.MapLocation;

    public class PartsChangeSignal implements Signal {
        private var loc:MapLocation;
        private var parts:Number;

        public function PartsChangeSignal(loc:MapLocation, parts:Number) {
            this.loc = loc;
            this.parts = parts;
        }

        public function getLocation():MapLocation {
            return loc;
        }

        public function getParts():Number {
            return parts;
        }

        public function accept(handler:SignalHandler):* {
            handler.visitPartsChangeSignal(this);
        }

    }

}