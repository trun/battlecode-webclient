package battlecode.world.signals {
	import battlecode.world.signals.SignalHandler;
	
	public class EvolutionSignal implements Signal {
		
		private var robotID:uint;
		private var type:String;
		
		public function EvolutionSignal(robotID:uint, type:String) {
			this.robotID = robotID;
			this.type = type;
		}
		
		public function getRobotID():uint {
			return robotID;
		}
		
		public function getType():String {
			return type;
		}
		
		public function accept(handler:SignalHandler):* {
			return handler.visitEvolutionSignal(this);
		}
		
	}
	
}