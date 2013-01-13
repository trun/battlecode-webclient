package battlecode.world.signals {
    import battlecode.common.Team;

	public class FluxChangeSignal implements Signal {
		private var fluxA:Number, fluxB:Number;

		public function FluxChangeSignal(fluxA:Number, fluxB:Number) {
            this.fluxA = fluxA;
            this.fluxB = fluxB;
		}
		
		public function getFlux(team:String):Number {
			return (team == Team.A) ? fluxA : fluxB;
		}
		
		public function accept(handler:SignalHandler):*{
			handler.visitFluxChangeSignal(this);
		}
		
	}

}