package battlecode.world.signals {
	
	public interface Signal {
		
		function accept(handler:SignalHandler):*;
		
	}
	
}