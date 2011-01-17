package battlecode.client.util {
	import battlecode.client.viewer.render.ImageAssets;
	import battlecode.events.MatchLoadProgressEvent;
	import battlecode.serial.MatchLoader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import mx.containers.VBox;
	import mx.controls.ProgressBar;
	import mx.controls.ProgressBarLabelPlacement;
	import mx.controls.ProgressBarMode;
	import mx.events.FlexEvent;
	
	public class MatchLoadProgressBar extends VBox {
		
		private var parseProgressBar:ProgressBar;
		private var matchProgressBar:ProgressBar;
		
		public function MatchLoadProgressBar(matchLoader:MatchLoader) {
			parseProgressBar = new ProgressBar();
			parseProgressBar.mode = ProgressBarMode.MANUAL;
			parseProgressBar.labelPlacement = ProgressBarLabelPlacement.BOTTOM;
			parseProgressBar.label = "Loading match...";
			parseProgressBar.percentWidth = 80;
			parseProgressBar.maximum = 100;
			
			matchProgressBar = new ProgressBar();
			matchProgressBar.enabled = false;
			matchProgressBar.mode = ProgressBarMode.MANUAL;
			matchProgressBar.percentWidth = 80;
			matchProgressBar.label = "";
			matchProgressBar.maximum = matchLoader.getNumMatches();
			
			matchLoader.addEventListener(ProgressEvent.PROGRESS, onMatchDownloadProgress);
			matchLoader.addEventListener(Event.COMPLETE, onMatchDownloadComplete);
			matchLoader.addEventListener(MatchLoadProgressEvent.MATCH_PARSE_PROGRESS, onMatchParseProgress);
			matchLoader.addEventListener(MatchLoadProgressEvent.GAME_PARSE_PROGRESS, onGameParseProgress);
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		private function onMatchDownloadProgress(e:ProgressEvent):void {
			parseProgressBar.setProgress(e.bytesLoaded, e.bytesTotal);
		}
		
		private function onMatchDownloadComplete(e:Event):void {
			matchProgressBar.enabled = true;
			parseProgressBar.label = "Parsing match...";
			matchProgressBar.label = "%1 of %2";
		}
		
		private function onMatchParseProgress(e:MatchLoadProgressEvent):void {
			matchProgressBar.setProgress(e.itemsComplete, e.itemsTotal);
		}
		
		private function onGameParseProgress(e:MatchLoadProgressEvent):void {
			parseProgressBar.setProgress(e.itemsComplete, e.itemsTotal);
		}
		
		private function onCreationComplete(e:Event):void {
			setStyle("backgroundImage", ImageAssets.GRADIENT_BACKGROUND);
			setStyle("backgroundSize", "100%");
			setStyle("verticalAlign", "middle");
			setStyle("horizontalAlign", "center");
			setStyle("borderStyle", "solid");
			setStyle("borderColor", "#000000");
			
			setStyle("paddingTop", 10);
			setStyle("paddingBottom", 10);
			
			addChild(parseProgressBar);
			addChild(matchProgressBar);
		}
		
	}
	
}