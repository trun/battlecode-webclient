package battlecode.world.signals {
import battlecode.common.Team;

public class TeamOreSignal implements Signal {
        private var oreA:Number;
        private var oreB:Number;

        public function TeamOreSignal(oreA:Number, oreB:Number) {
            this.oreA = oreA;
            this.oreB = oreB;
        }

        public function getOre(team:String):Number {
            return team == Team.A ? oreA : oreB;
        }

        public function accept(handler:SignalHandler):* {
            return handler.visitTeamOreSignal(this);
        }

    }

}