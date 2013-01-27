package battlecode.client.viewer {
    import battlecode.client.viewer.render.DrawDominationBar;
    import battlecode.client.viewer.render.DrawHUD;
    import battlecode.client.viewer.render.DrawMap;
    import battlecode.client.viewer.render.RenderConfiguration;
    import battlecode.common.Team;
    import battlecode.events.MatchEvent;

    import flash.display.InteractiveObject;
    import flash.events.Event;
    import flash.events.KeyboardEvent;

    import mx.binding.utils.ChangeWatcher;
    import mx.containers.HBox;
    import mx.containers.VBox;
    import mx.events.FlexEvent;

    /*
     * ----------------------
     * |       Dom Bar      |
     * |--------------------|
     * |                    |
     * |       DrawMap      |
     * |                    |
     * |                    |
     * ----------------------
     */
    public class GameCanvas extends HBox {
        private var controller:MatchController;
        private var watchers:Vector.<ChangeWatcher>;

        private var vbox:VBox; // container for map
        private var sideBoxA:VBox;
        private var sideBoxB:VBox;
        private var drawMap:DrawMap;

        public function GameCanvas(controller:MatchController) {
            super();

            this.percentWidth = 100;
            this.percentHeight = 100;

            this.vbox = new VBox();
            this.drawMap = new DrawMap(controller);
            this.sideBoxA = new DrawHUD(controller, Team.A);
            this.sideBoxB = new DrawHUD(controller, Team.B);

            this.controller = controller;
            this.controller.addEventListener(MatchEvent.ROUND_CHANGE, onRoundChange);
            this.controller.addEventListener(MatchEvent.MATCH_CHANGE, onMatchChange);

            this.setStyle("paddingLeft", 0);
            this.setStyle("paddingTop", 0);
            this.setStyle("paddingBottom", 0);
            this.setStyle("paddingRight", 0);
            this.setStyle("horizontalGap", 0);
            this.setStyle("verticalGap", 0);

            vbox.percentWidth = 100;
            vbox.percentHeight = 100;
            vbox.autoLayout = false;
            vbox.setStyle("paddingLeft", 0);
            vbox.setStyle("paddingTop", 0);
            vbox.setStyle("paddingBottom", 0);
            vbox.setStyle("paddingRight", 0);

            this.addChild(sideBoxA);
            this.addChild(vbox);
            this.addChild(sideBoxB);
            vbox.addChild(drawMap);

            this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
        }

        private function centerMap():void {
            if (width == 0 || height == 0) return;

            var containerWidth:Number = vbox.width;
            var containerHeight:Number = vbox.height;

            var mapWidth:uint = drawMap.getMapWidth();
            var mapHeight:uint = drawMap.getMapHeight();
            var scalingFactor:Number = Math.min(containerWidth / mapWidth, containerHeight / mapHeight);

            RenderConfiguration.setScalingFactor(scalingFactor);
            drawMap.redrawAll();
            drawMap.x = (containerWidth - (mapWidth * scalingFactor)) / 2;
            drawMap.y = (containerHeight - (mapHeight * scalingFactor)) / 2;
        }

        private function onCreationComplete(e:Event):void {
            this.watchers = new Vector.<ChangeWatcher>();
            this.watchers.push(ChangeWatcher.watch(this, "width", onSizeChange));
            this.watchers.push(ChangeWatcher.watch(this, "height", onSizeChange));
            this.watchers.push(ChangeWatcher.watch(vbox, "width", onSizeChange));
            this.watchers.push(ChangeWatcher.watch(vbox, "height", onSizeChange));

            centerMap();

            // can't be added until stage object is avail on creation complete
            this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }

        private function onRoundChange(e:MatchEvent):void {

        }

        private function onMatchChange(e:MatchEvent):void {
            centerMap();
            controller.currentRound += 1;
        }

        // listens for width/height changes to recenter map
        private function onSizeChange(e:Event):void {
            centerMap();
        }

        // listens for key presses to update the render configuration
        private function onKeyDown(e:KeyboardEvent):void {
            if (e.ctrlKey || e.altKey) return;

            switch (String.fromCharCode(e.charCode)) {
                case "B":
                case "b":
                    RenderConfiguration.toggleBroadcast();
                    break;
                case "D":
                case "d":
                    RenderConfiguration.toggleDiscrete();
                    break;
                case "E":
                case "e":
                    RenderConfiguration.toggleEnergon();
                    break;
                case "F":
                case "f":
                    controller.fastForwarding = !controller.fastForwarding;
                    break;
                case "G":
                case "g":
                    RenderConfiguration.toggleGridlines();
                    break;
                case "H":
                case "h":
                    RenderConfiguration.toggleDrawHeight();
                    break;
                case "K":
                case "k":
                    controller.keyframeRate = (controller.keyframeRate) ? 0 : 50; // toggle keyframing
                    break;
                case "M":
                case "m":
                    RenderConfiguration.toggleMines();
                    break;
                case "O":
                case "o":
                    RenderConfiguration.toggleHats();
                    break;
                case "S":
                case "s":
                    if (!trySkip(200)) if (!trySkip(100)) trySkip(50); // skip ahead
                    break;
                case "X":
                case "x":
                    RenderConfiguration.toggleExplosions();
                    break;
                case " ":
                    var focusObj:InteractiveObject = this.stage.focus;
                    this.stage.focus = null; // hack to prevent space bar from activating other buttons
                    this.stage.focus = focusObj;
                    if (controller.currentRound == controller.match.getRounds() && controller.currentMatch < controller.totalMatches) {
                        controller.currentMatch++;
                    }
                    controller.playing = !controller.playing; // toggle play/pause
                    break;
            }
        }

        private function trySkip(rounds:uint):Boolean {
            if (controller.currentRound + rounds < controller.match.getRounds()) {
                controller.currentRound += rounds;
                return true;
            }
            return false;
        }
    }

}