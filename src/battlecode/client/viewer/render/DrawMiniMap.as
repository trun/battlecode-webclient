package battlecode.client.viewer.render {
    import battlecode.client.viewer.MatchController;
    import battlecode.common.MapLocation;
    import battlecode.common.Team;
    import battlecode.events.MatchEvent;
    import battlecode.events.MiniMapEvent;
    import battlecode.world.GameMap;

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.containers.Canvas;
    import mx.core.UIComponent;

    public class DrawMiniMap extends Canvas {
        private var controller:MatchController;

        private var mapCanvas:UIComponent;
        private var viewerCanvas:UIComponent;
        private var viewerOffsetX:Number = 0;
        private var viewerOffsetY:Number = 0;
        private var viewerWidthPercent:Number = 1;
        private var viewerHeightPercent:Number = 1;

        public function DrawMiniMap(controller:MatchController) {
            super();

            this.width = 250;
            this.height = 300;

            this.controller = controller;
            this.controller.addEventListener(MatchEvent.ROUND_CHANGE, onRoundChange);
            this.controller.addEventListener(MatchEvent.MATCH_CHANGE, onMatchChange);
            this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            this.addEventListener(MouseEvent.MOUSE_DOWN, centerViewer);
            this.addEventListener(MouseEvent.MOUSE_MOVE, centerViewer);

            this.mapCanvas = new UIComponent();
            this.viewerCanvas = new UIComponent();

            this.addChild(mapCanvas);
            this.addChild(viewerCanvas);
        }

        public function setViewerBounds(viewerWidthPercent:Number, viewerHeightPercent:Number):void {
            this.viewerWidthPercent = viewerWidthPercent;
            this.viewerHeightPercent = viewerHeightPercent;
            drawViewer();
        }

        ///////////////////////////////////////////////////////
        ////////////////// DRAWING METHODS ////////////////////
        ///////////////////////////////////////////////////////

        public function redrawAll():void {
            drawMap();
            drawViewer();
        }

        private function drawMap():void {
            var i:uint, j:uint;
            var colors:Array = []; // uint[][]
            var map:GameMap = controller.match.getMap();
            var rubble:Array = controller.currentState.getRubble();
            var parts:Array = controller.currentState.getParts();
            for (i = 0; i < map.getHeight(); i++) {
                var colorsRow:Array = [];
                for (j = 0; j < map.getWidth(); j++) {
                    if (parts[i][j] > 0) {
                        colorsRow.push(0xFFC65C);
                    } else if (rubble[i][j] > 100) {
                        colorsRow.push(0x000000);
                    } else if (rubble[i][j] > 50) {
                        colorsRow.push(0x999999);
                    } else {
                        colorsRow.push(0xCCCCCC);
                    }
                }
                colors.push(colorsRow);
            }

            var origin:MapLocation = map.getOrigin();
            var o:DrawRobot, loc:MapLocation;
            for each (o in controller.currentState.getGroundRobots()) {
                loc = o.getLocation();
                i = (loc.getY() - origin.getY());
                j = (loc.getX() - origin.getX());
                if (o.getTeam() == Team.A) {
                    colors[i][j] = 0xFF6666;
                } else if (o.getTeam() == Team.B) {
                    colors[i][j] = 0x9999FF;
                } else {
                    colors[i][j] = 0xFFFF33; // TODO better neutral color
                }
            }

            for each (o in controller.currentState.getZombieRobots()) {
                loc = o.getLocation();
                i = (loc.getY() - origin.getY());
                j = (loc.getX() - origin.getX());
                colors[i][j] = 0x66FF66;
            }

            var s:uint = Math.min(width / map.getWidth(), height / map.getHeight());
            var offsetX:uint = (width - (map.getWidth() * s)) / 2;
            var offsetY:uint = height - (map.getHeight() * s);

            mapCanvas.graphics.clear();
            mapCanvas.graphics.lineStyle();
            for (i = 0; i < map.getHeight(); i++) {
                for (j = 0; j < map.getWidth(); j++) {
                    mapCanvas.graphics.beginFill(colors[i][j]);
                    mapCanvas.graphics.drawRect(offsetX + j * s, offsetY + i * s, s, s);
                    mapCanvas.graphics.endFill();
                }
            }
        }

        private function drawViewer():void {
            var map:GameMap = controller.match.getMap();
            var s:uint = Math.min(width / map.getWidth(), height / map.getHeight());
            var offsetX:uint = (width - (map.getWidth() * s)) / 2;
            var offsetY:uint = height - (map.getHeight() * s);

            var viewerXPercent:Number = viewerOffsetX / (map.getWidth() * s);
            var viewerYPercent:Number = viewerOffsetY / (map.getHeight() * s);

            dispatchEvent(new MiniMapEvent(MiniMapEvent.UPDATE_VIEWER, viewerXPercent, viewerYPercent));

            viewerCanvas.graphics.clear();
            viewerCanvas.graphics.lineStyle(3, 0xFFFFFF);
            viewerCanvas.graphics.drawRect(
                    offsetX + viewerOffsetX,
                    offsetY + viewerOffsetY,
                    map.getWidth() * s * viewerWidthPercent,
                    map.getHeight() * s * viewerHeightPercent
            );
        }

        ///////////////////////////////////////////////////////
        //////////////////// EVENT HANDLERS ///////////////////
        ///////////////////////////////////////////////////////

        private function onEnterFrame(e:Event):void {
            mapCanvas.visible = RenderConfiguration.showMinimap();
            viewerCanvas.visible = !RenderConfiguration.isScaleToFit();
        }

        private function centerViewer(e:MouseEvent):void {
            if (!e.buttonDown || RenderConfiguration.isScaleToFit()) {
                return;
            }

            var map:GameMap = controller.match.getMap();
            var s:uint = Math.min(width / map.getWidth(), height / map.getHeight());
            var offsetX:uint = (width - (map.getWidth() * s)) / 2;
            var offsetY:uint = height - (map.getHeight() * s);

            var viewerWidth:Number = map.getWidth() * s * viewerWidthPercent;
            var viewerHeight:Number = map.getHeight() * s * viewerHeightPercent;

            // find the new center of the viewer box
            var viewerCenterX:Number = e.localX - offsetX;
            var viewerCenterY:Number = e.localY - offsetY;

            // re-center the viewer box to keep it on the screen
            viewerOffsetX = viewerCenterX - viewerWidth / 2;
            viewerOffsetX = Math.max(viewerOffsetX, 0);
            viewerOffsetX = Math.min(viewerOffsetX, map.getWidth() * s - viewerWidth);

            viewerOffsetY = viewerCenterY - viewerHeight / 2;
            viewerOffsetY = Math.max(viewerOffsetY, 0);
            viewerOffsetY = Math.min(viewerOffsetY, map.getHeight() * s - viewerHeight);

            drawViewer();
        }

        private function onRoundChange(e:MatchEvent):void {
            drawMap();
        }

        private function onMatchChange(e:MatchEvent):void {
            viewerOffsetX = 0;
            viewerOffsetY = 0;

            redrawAll();
        }

    }

}