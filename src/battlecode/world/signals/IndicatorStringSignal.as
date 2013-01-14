package battlecode.world.signals {

    public class IndicatorStringSignal implements Signal {
        private var robotID:uint;
        private var index:uint;
        private var indicatorString:String;

        public function IndicatorStringSignal(robotID:uint, index:uint, indicatorString:String) {
            this.robotID = robotID;
            this.index = index;
            this.indicatorString = indicatorString;
        }

        public function getRobotID():uint {
            return robotID;
        }

        public function getIndex():uint {
            return index;
        }

        public function getIndicatorString():String {
            return indicatorString;
        }

        public function accept(handler:SignalHandler):* {
            handler.visitIndicatorStringSignal(this);
        }

    }

}