package battlecode.world.signals {

    public interface SignalHandler {

        function visitAttackSignal(s:AttackSignal):*;

        function visitBroadcastSignal(s:BroadcastSignal):*;

        function visitCaptureSignal(s:CaptureSignal):*;

        function visitDeathSignal(s:DeathSignal):*;

        function visitEnergonChangeSignal(s:EnergonChangeSignal):*;

        function visitFluxChangeSignal(s:FluxChangeSignal):*;

        function visitHatSignal(s:HatSignal):*;

        function visitIndicatorStringSignal(s:IndicatorStringSignal):*;

        function visitMineSignal(s:MineSignal):*;

        function visitMineLayerSignal(s:MineLayerSignal):*;

        function visitMovementSignal(s:MovementSignal):*;

        function visitNodeBirthSignal(s:NodeBirthSignal):*;

        function visitResearchChangeSignal(s:ResearchChangeSignal):*;

        function visitShieldChangeSignal(s:ShieldChangeSignal):*;

        function visitSpawnSignal(s:SpawnSignal):*;

    }

}