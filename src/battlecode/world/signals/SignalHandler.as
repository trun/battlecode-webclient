package battlecode.world.signals {
	
	public interface SignalHandler {
		
		function visitAttackSignal(s:AttackSignal):*;
		
		function visitBroadcastSignal(s:BroadcastSignal):*;
		
		function visitConvexHullSignal(s:ConvexHullSignal):*;
		
		function visitDeathSignal(s:DeathSignal):*;
		
		function visitDeploySignal(s:DeploySignal):*;
		
		function visitDoTeleportSignal(s:DoTeleportSignal):*;
		
		function visitEnergonChangeSignal(s:EnergonChangeSignal):*;
		
		function visitEnergonTransferSignal(s:EnergonTransferSignal):*;
		
		function visitEvolutionSignal(s:EvolutionSignal):*;
		
		function visitFluxChangeSignal(s:FluxChangeSignal):*;
		
		function visitFluxTransferSignal(s:FluxTransferSignal):*;
		
		function visitIndicatorStringSignal(s:IndicatorStringSignal):*;
		
		function visitMineFluxSignal(s:MineFluxSignal):*;
		
		function visitMovementSignal(s:MovementSignal):*;
		
		function visitSetAuraSignal(s:SetAuraSignal):*;
		
		function visitSetDirectionSignal(s:SetDirectionSignal):*;
		
		function visitStartTeleportSignal(s:StartTeleportSignal):*;
		
		function visitSpawnSignal(s:SpawnSignal):*;
		
		function visitUndeploySignal(s:UndeploySignal):*;
		
	}
	
}