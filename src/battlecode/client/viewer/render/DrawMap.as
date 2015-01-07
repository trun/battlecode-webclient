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
        private var oreCanvas:UIComponent;
        private var groundUnitCanvas:UIComponent;

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
            this.oreCanvas = new UIComponent();
            this.groundUnitCanvas = new UIComponent();

            this.mapCanvas.cacheAsBitmap = true;
            this.gridCanvas.cacheAsBitmap = true;
            this.oreCanvas.cacheAsBitmap = true;

            this.addChild(mapCanvas);
            this.addChild(gridCanvas);
            this.addChild(oreCanvas);
            this.addChild(groundUnitCanvas);
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
            drawOre();

            var o:DrawObject;

            for each (o in controller.currentState.getGroundRobots()) {
                o.draw(true);
            }

            this.scrollRect = new Rectangle(this.mapCanvas.x, this.mapCanvas.y,
                    getMapWidth() * RenderConfiguration.getScalingFactor(),
                    getMapHeight() * RenderConfiguration.getScalingFactor());
        }

        private function drawMap():void {
            var i:uint, j:uint, tile:TerrainTile;
            var map:GameMap = controller.match.getMap();
            var terrain:Array = map.getTerrainTiles();
            var colorTransform:ColorTransform, scalar:uint;

            origin = map.getOrigin();

            this.mapCanvas.graphics.clear();
            for (i = 0; i < map.getHeight(); i++) {
                for (j = 0; j < map.getWidth(); j++) {
                    tile = terrain[i][j] as TerrainTile;
                    if (tile.getType() == TerrainTile.LAND) {
                        scalar = 0xFF * 0.9;
                        colorTransform = new ColorTransform(0, 0, 0, 1, scalar, scalar, scalar, 0);
                        this.mapCanvas.graphics.beginFill(colorTransform.color, 1.0);
                        this.mapCanvas.graphics.drawRect(j * getGridSize(), i * getGridSize(), getGridSize(), getGridSize());
                        this.mapCanvas.graphics.endFill();
                    } else {
                        colorTransform = new ColorTransform(0, 0, 0, 1, 0x00, 0x00, 0x99, 0);
                        this.mapCanvas.graphics.beginFill(colorTransform.color, 1.0);
                        this.mapCanvas.graphics.drawRect(j * getGridSize(), i * getGridSize(), getGridSize(), getGridSize());
                        this.mapCanvas.graphics.endFill();
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

        private function drawOre():void {
            var ore:Array = controller.currentState.getOre();
            var i:uint, j:uint, team:String;

            this.oreCanvas.graphics.clear();
            var g:Number = getGridSize();
            for (i = 0; i < ore.length; i++) {
                for (j = 0; j < ore[i].length; j++) {
                    var density:Number = Math.min(1, ore[i][j] / 100);
                    var w:Number = density * g;
                    this.oreCanvas.graphics.lineStyle();
                    this.oreCanvas.graphics.beginFill(0xB19CD9, 0.5);
                    this.oreCanvas.graphics.drawRect(i * g + (g - w) / 2, j * g + (g - w) / 2, w, w);
                    //this.oreCanvas.graphics.drawCircle((i + .5) * g, (j + .5) * g, w / 2);
                    this.oreCanvas.graphics.endFill();
                }
            }
        }

        private function drawUnits():void {
            var loc:MapLocation, i:uint, j:uint, robot:DrawRobot;
            var groundRobots:Object = controller.currentState.getGroundRobots();

            while (groundUnitCanvas.numChildren > 0)
                groundUnitCanvas.removeChildAt(0);

            for each (robot in groundRobots) {
                loc = robot.getLocation();
                j = (loc.getX() - origin.getX());
                i = (loc.getY() - origin.getY());
                robot.x = j * getGridSize() + getGridSize() / 2;
                robot.y = i * getGridSize() + getGridSize() / 2;
                robot.addEventListener(MouseEvent.CLICK, onRobotSelect, false, 0, true);
                groundUnitCanvas.addChild(robot);
                robot.draw();
            }
        }

        private function updateUnits():void {
            var loc:MapLocation, i:uint, j:uint, robot:DrawRobot;
            var groundRobots:Object = controller.currentState.getGroundRobots();

            for each (robot in groundRobots) {
                loc = robot.getLocation();
                j = (loc.getX() - origin.getX());
                i = (loc.getY() - origin.getY());
                robot.x = j * getGridSize() + getGridSize() / 2;
                robot.y = i * getGridSize() + getGridSize() / 2;
                if (!robot.parent && robot.isAlive()) {
                    robot.addEventListener(MouseEvent.CLICK, onRobotSelect, false, 0, true);
                    groundUnitCanvas.addChild(robot);
                }
                robot.draw();
            }
        }

        ///////////////////////////////////////////////////////
        //////////////////// EVENT HANDLERS ///////////////////
        ///////////////////////////////////////////////////////

        private function onEnterFrame(e:Event):void {
            gridCanvas.visible = RenderConfiguration.showGridlines();
            groundUnitCanvas.visible = RenderConfiguration.showGround();
            oreCanvas.visible = RenderConfiguration.showCows();
        }

        private function onRoundChange(e:MatchEvent):void {
            if (e.currentRound < lastRound) {
                drawUnits();
            }
            updateUnits();
            drawOre();

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