package battlecode.world.signals {
	import battlecode.world.signals.Signal;
	import battlecode.world.signals.SignalHandler;
	
	public class FluxChangeSignal implements Signal{
		
		private var robotIDs:Array; // uint[]
		private var flux:Array; // Number[]
		
		public function FluxChangeSignal(robotIDs:Array, flux:Array) {
			this.robotIDs = robotIDs;
			this.flux = flux;
		}
		
		public function getRobotIDs():Array {
			return robotIDs;
		}
		
		public function getFlux():Array {
			return flux;
		}
		
		public function accept(handler:SignalHandler):*{
			handler.visitFluxChangeSignal(this);
		}
		
	}

}