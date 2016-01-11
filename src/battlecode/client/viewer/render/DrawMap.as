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

    public class DrawMap extends Canvas {
        private var controller:MatchController;
        private var origin:MapLocation;

        // various canvases for layering and quick toggling of features
        private var mapCanvas:UIComponent;
        private var gridCanvas:UIComponent;
        private var rubbleCanvas:UIComponent;
        private var partsCanvas:UIComponent;
        private var groundUnitCanvas:UIComponent;
        private var zombieUnitCanvas:UIComponent;

        // optimizations for caching
        private var lastRound:uint = 0;

        public function DrawMap(controller:MatchController) {
            super();

            this.controller = controller;
            this.controller.addEventListener(MatchEvent.ROUND_CHANGE, onRoundChange);
            this.controller.addEventListener(MatchEvent.MATCH_CHANGE, onMatchChange);
            this.addEventListener(Event.ENTER_FRAME, onEnterFrame);

            this.mapCanvas = new UIComponent();
            this.gridCanvas = new UIComponent();
            this.rubbleCanvas = new UIComponent();
            this.partsCanvas = new UIComponent();
            this.groundUnitCanvas = new UIComponent();
            this.zombieUnitCanvas = new UIComponent();

            this.mapCanvas.cacheAsBitmap = true;
            this.gridCanvas.cacheAsBitmap = true;

            this.addChild(mapCanvas);
            this.addChild(rubbleCanvas);
            this.addChild(partsCanvas);
            this.addChild(gridCanvas);
            this.addChild(groundUnitCanvas);
            this.addChild(zombieUnitCanvas);
        }

        ///////////////////////////////////////////////////////
        ////////////////// UTILITY METHODS ////////////////////
        ///////////////////////////////////////////////////////

        public function getMapWidth():uint {
            if (controller.match)
                return controller.match.getMap().getWidth() * RenderConfiguration.GRID_SIZE;
            return 0;
        }

        public function getMapHeight():uint {
            if (controller.match)
                return controller.match.getMap().getHeight() * RenderConfiguration.GRID_SIZE + 5;
            return 0;
        }

        private function getGridSize():Number {
            return RenderConfiguration.getGridSize();
        }

        ///////////////////////////////////////////////////////
        ////////////////// DRAWING METHODS ////////////////////
        ///////////////////////////////////////////////////////

        public function redrawAll():void {
            drawMap();
            drawGridlines();
            drawUnits();
            drawRubble();
            drawParts();

            var o:DrawObject;

            for each (o in controller.currentState.getGroundRobots()) {
                o.draw(true);
            }

            for each (o in controller.currentState.getZombieRobots()) {
                o.draw(true);
            }

//            this.scrollRect = new Rectangle(this.mapCanvas.x, this.mapCanvas.y,
//                    getMapWidth() * RenderConfiguration.getScalingFactor(),
//                    getMapHeight() * RenderConfiguration.getScalingFactor());
        }

        private function drawMap():void {
            var i:uint, j:uint, tile:TerrainTile;
            var map:GameMap = controller.match.getMap();
            var terrain:Array = map.getTerrainTiles();
            var colorTransform:ColorTransform, scalar:uint;
            var g:Number = getGridSize();

            origin = map.getOrigin();

            this.mapCanvas.graphics.clear();

            // draw terrain
            for (i = 0; i < map.getHeight(); i++) {
                for (j = 0; j < map.getWidth(); j++) {
                    tile = terrain[i][j] as TerrainTile;
                    if (tile.getType() == TerrainTile.LAND) {
                        scalar = 0xFF * 0.9;
                        colorTransform = new ColorTransform(0, 0, 0, 1, scalar, scalar, scalar, 0);
                        this.mapCanvas.graphics.beginFill(colorTransform.color, 1.0);
                        this.mapCanvas.graphics.drawRect(j * g, i * g, g, g);
                        this.mapCanvas.graphics.endFill();
                    } else {
                        colorTransform = new ColorTransform(0, 0, 0, 1, 0x00, 0x00, 0x99, 0);
                        this.mapCanvas.graphics.beginFill(colorTransform.color, 1.0);
                        this.mapCanvas.graphics.drawRect(j * g, i * g, g, g);
                        this.mapCanvas.graphics.endFill();
                    }
                }
            }

            // draw void outlines
            for (i = 0; i < map.getHeight(); i++) {
                for (j = 0; j < map.getWidth(); j++) {
                    tile = terrain[i][j] as TerrainTile;
                    if (tile.getType() == TerrainTile.VOID) {
                        this.mapCanvas.graphics.lineStyle(2, 0xFFFFFF);
                        if (i > 0 && terrain[i-1][j].getType() == TerrainTile.LAND) {
                            this.mapCanvas.graphics.moveTo(j * g, i * g);
                            this.mapCanvas.graphics.lineTo((j + 1) * g, i * g);
                        }
                        if (j > 0 && terrain[i][j-1].getType() == TerrainTile.LAND) {
                            this.mapCanvas.graphics.moveTo(j * g, i * g);
                            this.mapCanvas.graphics.lineTo(j * g, (i + 1) * g);
                        }
                        if (i < map.getHeight() - 1 && terrain[i+1][j].getType() == TerrainTile.LAND) {
                            this.mapCanvas.graphics.moveTo(j * g, (i + 1) * g);
                            this.mapCanvas.graphics.lineTo((j + 1) * g, (i + 1) * g);
                        }
                        if (j < map.getWidth() - 1 && terrain[i][j+1].getType() == TerrainTile.LAND) {
                            this.mapCanvas.graphics.moveTo((j + 1) * g, i * g);
                            this.mapCanvas.graphics.lineTo((j + 1) * g, (i + 1) * g);
                        }
                        this.mapCanvas.graphics.lineStyle();
                    }
                }
            }
        }

        private function drawGridlines():void {
            var i:uint, j:uint;
            var map:GameMap = controller.match.getMap();

            this.gridCanvas.graphics.clear();
            for (i = 0; i < map.getHeight(); i++) {
                for (j = 0; j < map.getWidth(); j++) {
                    this.gridCanvas.graphics.lineStyle(.5, 0x999999, 0.3);
                    this.gridCanvas.graphics.drawRect(j * getGridSize(), i * getGridSize(), getGridSize(), getGridSize());
                }
            }
        }

        private function drawRubble():void {
            var terrain:Array = controller.match.getMap().getTerrainTiles();
            var rubble:Array = controller.currentState.getRubble();
            var i:uint, j:uint;

            this.rubbleCanvas.graphics.clear();
            this.rubbleCanvas.graphics.lineStyle();
            var g:Number = getGridSize();
            for (i = 0; i < rubble.length; i++) {
                for (j = 0; j < rubble[i].length; j++) {
                    var tile:TerrainTile = terrain[i][j] as TerrainTile;
                    if (tile.getType() == TerrainTile.VOID) {
                        continue;
                    }

                    var density:Number = Math.min(1, rubble[i][j] / 100);
                    if (density <= .5) {
                        continue;
                    }

                    var color:uint = density < 1 ? 0x999999 : 0x000000;
                    this.rubbleCanvas.graphics.beginFill(color, 1.0);
                    this.rubbleCanvas.graphics.drawRect(j * g, i * g, g, g);
                    this.rubbleCanvas.graphics.endFill();
                }
            }
        }

        private function drawParts():void {
            var terrain:Array = controller.match.getMap().getTerrainTiles();
            var parts:Array = controller.currentState.getParts();
            var i:uint, j:uint;

            this.partsCanvas.graphics.clear();
            this.partsCanvas.graphics.lineStyle();
            var g:Number = getGridSize();
            for (i = 0; i < parts.length; i++) {
                for (j = 0; j < parts[i].length; j++) {
                    var tile:TerrainTile = terrain[i][j] as TerrainTile;
                    if (tile.getType() == TerrainTile.VOID) {
                        continue;
                    }

                    if (parts[i][j] <= 0) {
                        continue;
                    }

                    var density:Number = Math.max(.25, Math.min(1, parts[i][j] / 200));
                    this.partsCanvas.graphics.beginFill(0xF48F4B, 1);
                    this.partsCanvas.graphics.drawCircle(j * g + g / 2, i * g + g / 2, density * g / 2);
                    this.partsCanvas.graphics.endFill();
                }
            }
        }

        private function drawUnits():void {
            var loc:MapLocation, i:uint, j:uint, robot:DrawRobot;
            var groundRobots:Object = controller.currentState.getGroundRobots();
            var zombieRobots:Object = controller.currentState.getZombieRobots();
            var g:Number = getGridSize();

            while (groundUnitCanvas.numChildren > 0)
                groundUnitCanvas.removeChildAt(0);

            while (zombieUnitCanvas.numChildren > 0)
                zombieUnitCanvas.removeChildAt(0);

            for each (robot in groundRobots) {
                loc = robot.getLocation();
                j = (loc.getX() - origin.getX());
                i = (loc.getY() - origin.getY());
                robot.x = j * g + g / 2;
                robot.y = i * g + g / 2;
                robot.addEventListener(MouseEvent.CLICK, onRobotSelect, false, 0, true);
                groundUnitCanvas.addChild(robot);
                robot.draw();
                robot.x += robot.getDrawX();
                robot.y += robot.getDrawY();
            }

            for each (robot in zombieRobots) {
                loc = robot.getLocation();
                j = (loc.getX() - origin.getX());
                i = (loc.getY() - origin.getY());
                robot.x = j * g + g / 2;
                robot.y = i * g + g / 2;
                robot.addEventListener(MouseEvent.CLICK, onRobotSelect, false, 0, true);
                zombieUnitCanvas.addChild(robot);
                robot.draw();
                robot.x += robot.getDrawX();
                robot.y += robot.getDrawY();
            }
        }

        private function updateUnits():void {
            var loc:MapLocation, i:uint, j:uint, robot:DrawRobot;
            var groundRobots:Object = controller.currentState.getGroundRobots();
            var zombieRobots:Object = controller.currentState.getZombieRobots();
            var g:Number = getGridSize();

            for each (robot in groundRobots) {
                loc = robot.getLocation();
                j = (loc.getX() - origin.getX());
                i = (loc.getY() - origin.getY());
                robot.x = j * g + g / 2;
                robot.y = i * g + g / 2;
                if (!robot.parent && robot.isAlive()) {
                    robot.addEventListener(MouseEvent.CLICK, onRobotSelect, false, 0, true);
                    groundUnitCanvas.addChild(robot);
                }
                robot.draw();
                robot.x += robot.getDrawX();
                robot.y += robot.getDrawY();
            }

            for each (robot in zombieRobots) {
                loc = robot.getLocation();
                j = (loc.getX() - origin.getX());
                i = (loc.getY() - origin.getY());
                robot.x = j * g + g / 2;
                robot.y = i * g + g / 2;
                if (!robot.parent && robot.isAlive()) {
                    robot.addEventListener(MouseEvent.CLICK, onRobotSelect, false, 0, true);
                    zombieUnitCanvas.addChild(robot);
                }
                robot.draw();
                robot.x += robot.getDrawX();
                robot.y += robot.getDrawY();
            }
        }

        ///////////////////////////////////////////////////////
        //////////////////// EVENT HANDLERS ///////////////////
        ///////////////////////////////////////////////////////

        private function onEnterFrame(e:Event):void {
            gridCanvas.visible = RenderConfiguration.showGridlines();
            groundUnitCanvas.visible = RenderConfiguration.showGround();
            zombieUnitCanvas.visible = RenderConfiguration.showZombies();
            partsCanvas.visible = RenderConfiguration.showParts();
            rubbleCanvas.visible = RenderConfiguration.showRubble();
        }

        private function onRoundChange(e:MatchEvent):void {
            if (e.currentRound < lastRound) {
                drawUnits();
            }
            updateUnits();
            drawRubble();
            drawParts();

            lastRound = e.currentRound;

            this.visible = (e.currentRound != 0);
        }

        private function onMatchChange(e:MatchEvent):void {
            redrawAll();
        }

        private function onRobotSelect(e:MouseEvent):void {
            var x:Number, y:Number;

            if (RenderConfiguration.isTournament())
                return;

            if (controller.selectedRobot && controller.selectedRobot.parent) {
                controller.selectedRobot.setSelected(false);
                x = controller.selectedRobot.x;
                y = controller.selectedRobot.y;
                controller.selectedRobot.draw(true);
                controller.selectedRobot.x = x;
                controller.selectedRobot.y = y;
            }

            var robot:DrawRobot = e.currentTarget as DrawRobot;
            robot.setSelected(true);
            x = robot.x;
            y = robot.y;
            robot.draw(true);
            robot.x = x;
            robot.y = y;
            controller.selectedRobot = robot;
        }

    }

}