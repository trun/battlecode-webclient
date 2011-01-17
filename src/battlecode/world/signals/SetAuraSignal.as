package battlecode.world.signals {
	import battlecode.world.signals.Signal;
	import battlecode.world.signals.SignalHandler;
	
	public class SetAuraSignal implements Signal {
		
		private var robotID:uint;
		private var aura:String;
		
		public function SetAuraSignal(robotID:uint, aura:String) {
			this.robotID = robotID;
			this.aura = aura;
		}
		
		public function getRobotID():uint {
			return robotID;
		}
		
		public function getAura():String {
			return aura;
		}
		
		public function accept(handler:SignalHandler):* {
			handler.visitSetAuraSignal(this);
		}
		
	}

}