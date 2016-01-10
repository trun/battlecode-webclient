package battlecode.world.signals {
    public class TypeChangeSignal implements Signal {
        private var robotID:uint;
        private var type:String;

        public function TypeChangeSignal(robotID:uint, type:String) {
            this.robotID = robotID;
            this.type = type;
        }

        public function getRobotID():uint {
            return robotID;
        }

        public function getType():String {
            return type;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitTypeChangeSignal(this);
        }

    }

}