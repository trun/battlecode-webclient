package battlecode.client.viewer.render {
	import battlecode.client.viewer.MatchController;
	import battlecode.common.MapLocation;
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
		private var groundUnitCanvas:UIComponent;
		private var encampmentCanvas:UIComponent;
		
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
			this.groundUnitCanvas = new UIComponent();
			this.encampmentCanvas = new UIComponent();
			
			this.mapCanvas.cacheAsBitmap = true;
			this.gridCanvas.cacheAsBitmap = true;
			
			this.addChild(mapCanvas);
			this.addChild(gridCanvas);
			this.addChild(groundUnitCanvas);
			this.addChild(encampmentCanvas);
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

			for each (o in controller.currentState.getGroundRobots()) {
				o.draw(true);
			}

            var o:DrawObject;
            for each (o in controller.currentState.getEncampments()) {
                o.draw(true);
            }

			this.scrollRect = new Rectangle(this.mapCanvas.x, this.mapCanvas.y,
					getMapWidth() * RenderConfiguration.getScalingFactor(),
					getMapHeight() * RenderConfiguration.getScalingFactor());
		}
		
		private function drawMap():void {
			var i:uint, j:uint, tile:TerrainTile;
			var map:GameMap = controller.match.getMap();
			var terrain:Array = [];
			var colorTransform:ColorTransform, scalar:uint;
			
			origin = map.getOrigin();
			
			var max:uint = 0, min:uint = 100;
			for (i = 0; i < map.getHeight(); i++) {
				for (j = 0; j < map.getWidth(); j++) {
					tile = terrain[i][j] as TerrainTile;
					max = Math.max(tile.getHeight(), max);
					min = Math.min(tile.getHeight(), min);
				}
			}
			
			this.mapCanvas.graphics.clear();
			for (i = 0; i < map.getHeight(); i++) {
				for (j = 0; j < map.getWidth(); j++) {
					tile = terrain[i][j] as TerrainTile;
					if (tile.getType() == TerrainTile.LAND) {
						scalar = 0xFF * (tile.getHeight() / max);
						colorTransform = new ColorTransform(0, 0, 0, 1, scalar, scalar, scalar, 0);
						this.mapCanvas.graphics.beginFill(colorTransform.color, 1.0);
						this.mapCanvas.graphics.drawRect(j * getGridSize(), i * getGridSize(), getGridSize(), getGridSize());
						this.mapCanvas.graphics.endFill();
					} else {
						this.mapCanvas.graphics.beginFill(0x000000, 1.0);
						this.mapCanvas.graphics.drawRect(j * getGridSize(), i * getGridSize(), getGridSize(), getGridSize());
						this.mapCanvas.graphics.endFill();
					}
				}
			}
		}
		
		private function drawFlux():void {
			var i:uint, j:uint, tile:TerrainTile;
			var map:GameMap = controller.match.getMap();
			var terrain:Array = [];
			var colorTransform:ColorTransform, scalar:uint;
		}
		
		private function drawGridlines():void {
			var i:uint, j:uint;
			var map:GameMap = controller.match.getMap();
			
			this.gridCanvas.graphics.clear();
			for (i = 0; i < map.getHeight(); i++) {
				for (j = 0; j < map.getWidth(); j++) {
					this.gridCanvas.graphics.lineStyle(.5, 0x666666, 0.5);
					this.gridCanvas.graphics.drawRect(j * getGridSize(), i * getGridSize(), getGridSize(), getGridSize());
				}
			}
		}
		
		private function drawUnits():void {
			var loc:MapLocation, i:uint, j:uint, robot:DrawRobot;
			var groundRobots:Object = controller.currentState.getGroundRobots();
			var encampments:Object = controller.currentState.getEncampments();
			
			while (groundUnitCanvas.numChildren > 0)
				groundUnitCanvas.removeChildAt(0);
			
			while (encampmentCanvas.numChildren > 0)
				encampmentCanvas.removeChildAt(0);
			
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
			
			for each (robot in encampments) {
				loc = robot.getLocation();
				j = (loc.getX() - origin.getX());
				i = (loc.getY() - origin.getY());
				robot.x = j * getGridSize() + getGridSize() / 2;
				robot.y = i * getGridSize() + getGridSize() / 2;
				robot.addEventListener(MouseEvent.CLICK, onRobotSelect, false, 0, true);
				encampmentCanvas.addChild(robot);
				robot.draw();
			}
		}
		
		private function updateUnits():void {
			var loc:MapLocation, i:uint, j:uint, robot:DrawRobot;
			var groundRobots:Object = controller.currentState.getGroundRobots();
			var encampments:Object = controller.currentState.getEncampments();
			
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
			
			for each (robot in encampments) {
				loc = robot.getLocation();
				j = (loc.getX() - origin.getX());
				i = (loc.getY() - origin.getY());
				robot.x = j * getGridSize() + getGridSize() / 2;
				robot.y = i * getGridSize() + getGridSize() / 2;
				if (!robot.parent && robot.isAlive()) {
					robot.addEventListener(MouseEvent.CLICK, onRobotSelect, false, 0, true);
					encampmentCanvas.addChild(robot);
				}
				robot.draw();
			}
		}
		
		///////////////////////////////////////////////////////
		//////////////////// EVENT HANDLERS ///////////////////
		///////////////////////////////////////////////////////
		
		private function onEnterFrame(e:Event):void {
			gridCanvas.visible = RenderConfiguration.showGridlines();
			encampmentCanvas.visible = RenderConfiguration.showAir();
			groundUnitCanvas.visible = RenderConfiguration.showGround();
		}
		
		private function onRoundChange(e:MatchEvent):void {
			if (e.currentRound < lastRound) {
				drawUnits();
			}
			drawFlux();
			updateUnits();

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