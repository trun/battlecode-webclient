package battlecode.world.signals {
	
	public class DefaultSignalHandler implements SignalHandler {
		
		public function DefaultSignalHandler() { }
		
		public function visitAttackSignal(s:AttackSignal):* { return null; }
		
		public function visitBroadcastSignal(s:BroadcastSignal):* { return null; }
		
		public function visitConvexHullSignal(s:ConvexHullSignal):* { return null; }
		
		public function visitDeathSignal(s:DeathSignal):* { return null; }
		
		public function visitDeploySignal(s:DeploySignal):* { return null; }
		
		public function visitDoTeleportSignal(s:DoTeleportSignal):* { return null; }
		
		public function visitEnergonChangeSignal(s:EnergonChangeSignal):* { return null; }
		
		public function visitEnergonTransferSignal(s:EnergonTransferSignal):* { return null; }
		
		public function visitEvolutionSignal(s:EvolutionSignal):* { return null; }
		
		public function visitFluxChangeSignal(s:FluxChangeSignal):* { return null; }
		
		public function visitFluxTransferSignal(s:FluxTransferSignal):* { return null; }
		
		public function visitIndicatorStringSignal(s:IndicatorStringSignal):* { return null; }
		
		public function visitMineFluxSignal(s:MineFluxSignal):* { return null; }
		
		public function visitMovementSignal(s:MovementSignal):* { return null; }
		
		public function visitSetAuraSignal(s:SetAuraSignal):* { return null; }
		
		public function visitSetDirectionSignal(s:SetDirectionSignal):* { return null; }
		
		public function visitStartTeleportSignal(s:StartTeleportSignal):* { return null; }
		
		public function visitSpawnSignal(s:SpawnSignal):* { return null; }
		
		public function visitUndeploySignal(s:UndeploySignal):* { return null; };
		
	}
	
}