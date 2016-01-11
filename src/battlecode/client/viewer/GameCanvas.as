package battlecode.client.viewer {
    import battlecode.client.viewer.render.DrawHUD;
    import battlecode.client.viewer.render.DrawMap;
    import battlecode.client.viewer.render.DrawMiniMap;
    import battlecode.client.viewer.render.RenderConfiguration;
    import battlecode.common.Team;
    import battlecode.events.MatchEvent;

    import flash.display.InteractiveObject;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;

    import mx.binding.utils.ChangeWatcher;
    import mx.containers.HBox;
    import mx.containers.VBox;
    import mx.controls.Spacer;
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
        private var sideBox:VBox; // container for sidebar
        private var sideBoxA:VBox;
        private var sideBoxB:VBox;
        private var sideSpacer:Spacer;
        private var drawMiniMap:DrawMiniMap;
        private var drawMap:DrawMap;

        public function GameCanvas(controller:MatchController) {
            super();

            this.percentWidth = 100;
            this.percentHeight = 100;

            this.vbox = new VBox();
            this.drawMap = new DrawMap(controller);
            this.sideBox = new VBox();
            this.sideBoxA = new DrawHUD(controller, Team.A);
            this.sideBoxB = new DrawHUD(controller, Team.B);
            this.drawMiniMap = new DrawMiniMap(controller);

            this.controller = controller;
            this.controller.addEventListener(MatchEvent.ROUND_CHANGE, onRoundChange);
            this.controller.addEventListener(MatchEvent.MATCH_CHANGE, onMatchChange);

            this.setStyle("paddingLeft", 0);
            this.setStyle("paddingTop", 0);
            this.setStyle("paddingBottom", 0);
            this.setStyle("paddingRight", 0);
            this.setStyle("horizontalGap", 0);
            this.setStyle("verticalGap", 0);

            sideBox.width = 250;
            sideBox.percentHeight = 100;
            sideBox.setStyle("paddingLeft", 0);
            sideBox.setStyle("paddingTop", 0);
            sideBox.setStyle("paddingBottom", 0);
            sideBox.setStyle("paddingRight", 0);
            sideBox.setStyle("backgroundColor", 0x333333);

            vbox.percentWidth = 100;
            vbox.percentHeight = 100;
            vbox.autoLayout = false;
            vbox.setStyle("paddingLeft", 0);
            vbox.setStyle("paddingTop", 0);
            vbox.setStyle("paddingBottom", 0);
            vbox.setStyle("paddingRight", 0);

            this.addChild(sideBox);
            sideBox.addChild(sideBoxA);
            sideBox.addChild(sideBoxB);
            this.addChild(vbox);
            vbox.addChild(drawMap);

            sideSpacer = new Spacer();
            sideSpacer.percentHeight = 100;
            sideBox.addChild(sideSpacer);
            sideBox.addChild(drawMiniMap);

            this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
        }

        private function centerMap():void {
            if (width == 0 || height == 0) return;

            var containerWidth:Number = vbox.width;
            var containerHeight:Number = vbox.height;

            var mapWidth:uint = drawMap.getMapWidth();
            var mapHeight:uint = drawMap.getMapHeight();
            var scalingFactor:Number = Math.min(containerWidth / mapWidth, containerHeight / mapHeight);

            if (RenderConfiguration.isScaleToFit()) {
                RenderConfiguration.setScalingFactor(scalingFactor);
                drawMap.redrawAll();
                drawMap.scrollRect = null;
                drawMap.x = (containerWidth - (mapWidth * scalingFactor)) / 2;
                drawMap.y = 0;
            } else {
                RenderConfiguration.setScalingFactor(1);
                drawMap.redrawAll();
                drawMap.scrollRect = new Rectangle(0, 0, containerWidth, containerHeight);
                drawMap.x = 0;
                drawMap.y = 0;
            }
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

        // TODO scrolling via minimap
        private function onMapScroll(e:MouseEvent):void {
            var r:Rectangle = drawMap.scrollRect;
            var newX:Number = Math.max(0, Math.min(drawMap.getMapWidth() - vbox.width, r.x + e.delta));
            drawMap.scrollRect = new Rectangle(newX, r.y, vbox.width, vbox.height);
            var newY:Number = Math.max(0, Math.min(drawMap.getMapHeight() - vbox.height, r.y - e.delta));
            drawMap.scrollRect = new Rectangle(r.x, newY, vbox.width, vbox.height);
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
                    RenderConfiguration.toggleMinimap();
                    break;
                case "O":
                case "o":
                    RenderConfiguration.toggleHats();
                    break;
                case "P":
                case "p":
                    RenderConfiguration.toggleParts();
                    break;
                case "R":
                case "r":
                    RenderConfiguration.toggleRubble();
                    break;
                case "S":
                case "s":
                    if (!trySkip(200)) if (!trySkip(100)) trySkip(50); // skip ahead
                    break;
                case "X":
                case "x":
                    RenderConfiguration.toggleExplosions();
                    break;
                case "Z":
                case "z":
                    RenderConfiguration.toggleScaleToFit();
                    centerMap();
                    break;
                case " ":
                    // hack to prevent space bar from activating other buttons
                    var focusObj:InteractiveObject = this.stage.focus;
                    this.stage.focus = null;
                    this.stage.focus = focusObj;

                    // advance to next match if this one is done
                    if (controller.currentRound == controller.match.getRounds() && controller.currentMatch < controller.totalMatches) {
                        controller.currentMatch++;
                    }

                    // toggle play / pause if we're not at the end of a match
                    if (controller.currentRound < controller.match.getRounds()) {
                        controller.playing = !controller.playing;
                    }
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