package battlecode.world.signals {

    public interface SignalHandler {

        function visitAttackSignal(s:AttackSignal):*;

        function visitBashSignal(s:BashSignal):*;

        function visitBroadcastSignal(s:BroadcastSignal):*;

        function visitDeathSignal(s:DeathSignal):*;

        function visitHealthChangeSignal(s:HealthChangeSignal):*;

        function visitIndicatorStringSignal(s:IndicatorStringSignal):*;

        function visitRubbleChangeSignal(s:RubbleChangeSignal):*;

        function visitPartsChangeSignal(s:PartsChangeSignal):*;

        function visitMovementSignal(s:MovementSignal):*;

        function visitTeamOreSignal(s:TeamOreSignal):*;

        function visitSpawnSignal(s:SpawnSignal):*;

    }

}