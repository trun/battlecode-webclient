package battlecode.world.signals {

    public interface SignalHandler {

        function visitAttackSignal(s:AttackSignal):*;

        function visitBashSignal(s:BashSignal):*;

        function visitBroadcastSignal(s:BroadcastSignal):*;

        function visitCaptureSignal(s:CaptureSignal):*;

        function visitDeathSignal(s:DeathSignal):*;

        function visitRobotInfoSignal(s:RobotInfoSignal):*;

        function visitFluxChangeSignal(s:FluxChangeSignal):*;

        function visitIndicatorStringSignal(s:IndicatorStringSignal):*;

        function visitMovementSignal(s:MovementSignal):*;

        function visitNeutralsDensitySignal(s:NeutralsDensitySignal):*;

        function visitNeutralsTeamSignal(s:NeutralsTeamSignal):*;

        function visitTeamOreSignal(s:TeamOreSignal):*;

        function visitSpawnSignal(s:SpawnSignal):*;

    }

}