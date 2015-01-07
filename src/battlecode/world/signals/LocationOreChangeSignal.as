package battlecode.world.signals {
import battlecode.common.MapLocation;

    public class LocationOreChangeSignal implements Signal {
        private var loc:MapLocation;
        private var ore:Number;

        public function LocationOreChangeSignal(loc:MapLocation, ore:Number) {
            this.loc = loc;
            this.ore = ore;
        }

        public function getLocation():MapLocation {
            return loc;
        }

        public function getOre():Number {
            return ore;
        }

        public function accept(handler:SignalHandler):* {
            handler.visitLocationOreChangeSignal(this);
        }

    }

}