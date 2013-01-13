package battlecode.client.viewer {
	import battlecode.client.util.MatchLoadProgressBar;
	import battlecode.events.MatchEvent;
	import battlecode.events.MatchLoadProgressEvent;
	import battlecode.serial.MatchLoader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	
	public class MatchCanvas extends VBox {
		
		private var controlBar:ControlBar;
		private var gameCanvas:GameCanvas;
		
		private var progressBar:MatchLoadProgressBar;
		
		private var matchLoader:MatchLoader;
		private var controller:MatchController;
		
		public function MatchCanvas() {
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		private function onCreationComplete(e:Event):void {
			// resize component
			percentWidth = 100;
			percentHeight = 100;
			setStyle("verticalGap", 0);
			setStyle("verticalAlign", "middle");
			setStyle("horizontalAlign", "center");
			
			// create the match controller / loader
			controller = new MatchController();
			controlBar = new ControlBar(controller);
			gameCanvas = new GameCanvas(controller);
			matchLoader = new MatchLoader();
			
			// add the progress bar
			progressBar = new MatchLoadProgressBar(matchLoader);
			addChild(progressBar);
			
			// load the match file
			matchLoader.addEventListener(MatchLoadProgressEvent.MATCH_PARSE_COMPLETE, onMatchParseComplete);

			var noMatch:Boolean = true;
			if (this.parentApplication.parameters) {
				var params:Object = this.parentApplication.parameters;
				
				// load an absolute match file
				if (params.match_path) {
					matchLoader.load(params.match);
					noMatch = false;
				}
			}

			if (noMatch) {
				//Alert.show("No match file specified");
                matchLoader.load("../../../matches/match.rms");
			}
		}
		
		private function onMatchParseComplete(e:MatchLoadProgressEvent):void {
			controller.setMatches(matchLoader.getMatches());
			
			addChild(controlBar);
			addChild(gameCanvas);
			
			removeChild(progressBar);
		}
		
	}
	
}