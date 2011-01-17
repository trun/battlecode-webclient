package battlecode.serial {
	
	public class RoundDelta {
		
		private var signals:Array; // Signal[]
		
		public function RoundDelta(signals:Array) {
			this.signals = signals;
		}
		
		public function getSignals():Array {
			return signals;
		}
		
	}
	
}