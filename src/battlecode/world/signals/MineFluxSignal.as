package battlecode.world.signals {
	import battlecode.world.signals.Signal;
	import battlecode.world.signals.SignalHandler;
	
	public class MineFluxSignal implements Signal {
		
		private var locs:Array; // boolean[][]
		
		public function MineFluxSignal(locs:Array) {
			this.locs = locs;
		}
		
		public function getLocs():Array {
			return locs;
		}
		
		public function accept(handler:SignalHandler):* {
			handler.visitMineFluxSignal(this);
		}
		
	}

}