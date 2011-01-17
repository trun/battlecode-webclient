package battlecode.world.signals {
	import battlecode.common.MapLocation;
	import battlecode.world.signals.Signal;
	import battlecode.world.signals.SignalHandler;
	
	public class FluxTransferSignal implements Signal {
		
		private var robotID:uint;
		private var targetLoc:MapLocation;
		private var targetLevel:String;
		private var amount:Number;
		
		public function FluxTransferSignal(robotID:uint, targetLoc:MapLocation, targetLevel:String, amount:Number) {
			this.robotID = robotID;
			this.targetLoc = targetLoc;
			this.targetLevel = targetLevel;
			this.amount = amount;
		}
		
		public function getRobotID():uint {
			return robotID;
		}
		
		public function getTargetLoc():MapLocation {
			return targetLoc;
		}
		
		public function getTargetLevel():String {
			return targetLevel;
		}
		
		public function getAmount():Number {
			return amount;
		}
		
		public function accept(handler:SignalHandler):* {
			handler.visitFluxTransferSignal(this);
		}
		
	}

}