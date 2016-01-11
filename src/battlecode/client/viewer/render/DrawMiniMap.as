package battlecode.client.viewer.render {
    import battlecode.client.viewer.MatchController;
    import battlecode.common.MapLocation;
    import battlecode.common.Team;
    import battlecode.common.TerrainTile;
    import battlecode.events.MatchEvent;
    import battlecode.world.GameMap;

    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Rectangle;

    import mx.containers.Canvas;
    import mx.core.UIComponent;

    public class DrawMiniMap extends Canvas {
        private var controller:MatchController;
        private var mapCanvas:UIComponent;

        public function DrawMiniMap(controller:MatchController) {
            super();

            this.width = 250;
            this.height = 300;

            this.controller = controller;
            this.controller.addEventListener(MatchEvent.ROUND_CHANGE, onRoundChange);
            this.controller.addEventListener(MatchEvent.MATCH_CHANGE, onMatchChange);

            this.mapCanvas = new UIComponent();
            this.addChild(mapCanvas);
        }

        ///////////////////////////////////////////////////////
        ////////////////// DRAWING METHODS ////////////////////
        ///////////////////////////////////////////////////////

        public function redrawAll():void {
            drawMap();
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

        ///////////////////////////////////////////////////////
        //////////////////// EVENT HANDLERS ///////////////////
        ///////////////////////////////////////////////////////

        private function onRoundChange(e:MatchEvent):void {
            redrawAll();
        }

        private function onMatchChange(e:MatchEvent):void {
            redrawAll();
        }

    }

}