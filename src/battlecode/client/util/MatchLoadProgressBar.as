package battlecode.client.util {
    import battlecode.client.viewer.render.ImageAssets;
    import battlecode.events.ParseEvent;
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
            parseProgressBar.indeterminate = true;
            parseProgressBar.labelPlacement = ProgressBarLabelPlacement.BOTTOM;
            parseProgressBar.label = "Loading match...";
            parseProgressBar.percentWidth = 80;
            parseProgressBar.maximum = 100;

            matchProgressBar = new ProgressBar();
            matchProgressBar.enabled = false;
            matchProgressBar.mode = ProgressBarMode.MANUAL;
            matchProgressBar.percentWidth = 80;
            matchProgressBar.labelPlacement = ProgressBarLabelPlacement.BOTTOM;
            matchProgressBar.label = "";
            matchProgressBar.maximum = matchLoader.getNumMatches();

            matchLoader.addEventListener(ProgressEvent.PROGRESS, onMatchDownloadProgress);
            matchLoader.addEventListener(Event.COMPLETE, onMatchDownloadComplete);
            matchLoader.addEventListener(ParseEvent.PROGRESS, onMatchParseProgress);
            matchLoader.addEventListener(ParseEvent.COMPLETE, onMatchParseProgress);
            this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
        }

        private function onMatchDownloadProgress(e:ProgressEvent):void {
            parseProgressBar.setProgress(e.bytesLoaded, e.bytesTotal);
        }

        private function onMatchDownloadComplete(e:Event):void {
            parseProgressBar.indeterminate = false;
            parseProgressBar.label = "Parsing match...";
            matchProgressBar.enabled = true;
            matchProgressBar.label = "%1 of %2";
        }

        private function onMatchParseProgress(e:ParseEvent):void {
            parseProgressBar.setProgress(e.rowsParsed, e.rowsTotal);
            matchProgressBar.setProgress(e.matchesParsed + 1, e.matchesTotal);
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