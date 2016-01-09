package battlecode.world.signals {

    public class DefaultSignalHandler implements SignalHandler {

        public function DefaultSignalHandler() {
        }

        public function visitAttackSignal(s:AttackSignal):* {
            return null;
        }

        public function visitBashSignal(s:BashSignal):* {
            return null;
        }

        public function visitBroadcastSignal(s:BroadcastSignal):* {
            return null;
        }

        public function visitDeathSignal(s:DeathSignal):* {
            return null;
        }

        public function visitHealthChangeSignal(s:HealthChangeSignal):* {
            return null;
        }

        public function visitIndicatorStringSignal(s:IndicatorStringSignal):* {
            return null;
        }

        public function visitRubbleChangeSignal(s:RubbleChangeSignal):* {
            return null;
        }

        public function visitPartsChangeSignal(s:PartsChangeSignal):* {
            return null;
        }

        public function visitMovementSignal(s:MovementSignal):* {
            return null;
        }

        public function visitTeamOreSignal(s:TeamOreSignal):* {
            return null;
        }

        public function visitSpawnSignal(s:SpawnSignal):* {
            return null;
        }
    }

}