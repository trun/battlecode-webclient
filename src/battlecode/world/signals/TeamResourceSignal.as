package battlecode.world.signals {
    public class TeamResourceSignal implements Signal {
        private var team:String;
        private var resource:Number;

        public function TeamResourceSignal(team:String, resource:Number) {
            this.team = team;
            this.resource = resource;
        }

        public function getTeam():String {
            return team;
        }

        public function getResource():Number {
            return resource;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitTeamResourceSignal(this);
        }
    }
}