package battlecode.client.viewer {
    import battlecode.client.util.MatchLoadProgressBar;
    import battlecode.client.viewer.render.RenderConfiguration;
    import battlecode.events.ParseEvent;
    import battlecode.serial.MatchLoader;

    import flash.events.Event;
    import flash.net.FileFilter;
    import flash.net.FileReference;
    import flash.system.Capabilities;

    import mx.containers.VBox;
    import mx.controls.Alert;
    import mx.events.FlexEvent;

    public class MatchCanvas extends VBox {
        private var controlBar:ControlBar;
        private var gameCanvas:GameCanvas;

        private var progressBar:MatchLoadProgressBar;

        private var matchLoader:MatchLoader;
        private var controller:MatchController;

        private var file:FileReference;

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

            // load the render configuration
            RenderConfiguration.loadConfiguration();

            // load the match file
            matchLoader.addEventListener(ParseEvent.COMPLETE, onMatchParseComplete);

            if (this.parentApplication.parameters) {
                var params:Object = this.parentApplication.parameters;
                if (params.match) {
                    matchLoader.load(params.match);
                    return;
                }
                if (params.tournament == "true") {
                    RenderConfiguration.setTournamentMode(true);
                }
            }

            if (Capabilities.playerType == "StandAlone") {
                file = new FileReference();
                file.addEventListener(Event.SELECT, function (event:Event):void {
                    file.load();
                });
                file.addEventListener(Event.COMPLETE, function (event:Event):void {
                    matchLoader.loadData(file.data);
                });
                file.browse([new FileFilter("Battlecode Matches (*.rms)", "*.rms")]);
                return;
            }

            Alert.show("No match file specified");
        }

        private function onMatchParseComplete(e:ParseEvent):void {
            controller.setMatches(matchLoader.getMatches());

            addChild(controlBar);
            addChild(gameCanvas);

            removeChild(progressBar);
        }

    }

}