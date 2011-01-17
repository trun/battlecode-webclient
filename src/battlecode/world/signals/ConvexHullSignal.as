package battlecode.world.signals {
	import battlecode.world.signals.Signal;
	import battlecode.world.signals.SignalHandler;
	
	public class ConvexHullSignal implements Signal {
		
		private var team:String;
		private var hulls:Array; // MapLocation[][]
		
		public function ConvexHullSignal(team:String, hulls:Array) {
			this.team = team;
			this.hulls = hulls;
		}
		
		public function getTeam():String {
			return team;
		}
		
		public function getHulls():Array {
			return hulls;
		}
		
		public function accept(handler:SignalHandler):* {
			handler.visitConvexHullSignal(this);
		}
		
	}

}