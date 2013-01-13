package battlecode.client.viewer.render {
	import battlecode.client.viewer.MatchController;
	import battlecode.common.MapLocation;
	import battlecode.common.Team;
	import battlecode.common.TerrainTile;
	import battlecode.events.MatchEvent;
	import battlecode.world.GameMap;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import mx.binding.utils.ChangeWatcher;
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.events.FlexEvent;
	
	public class DrawMap extends Canvas {
		
		private var controller:MatchController;
		private var origin:MapLocation;
		
		// various canvases for layering and quick toggling of features
		private var mapCanvas:UIComponent;
		private var fluxCanvas:UIComponent;
		private var gridCanvas:UIComponent;
		private var groundUnitCanvas:UIComponent;
		private var convexHullCanvas:UIComponent;
		private var airUnitCanvas:UIComponent;
		
		// optimizations for caching
		private var lastRound:uint = 0;
		
		public function DrawMap(controller:MatchController) {
			super();
			
			this.controller = controller;
			this.controller.addEventListener(MatchEvent.ROUND_CHANGE, onRoundChange);
			this.controller.addEventListener(MatchEvent.MATCH_CHANGE, onMatchChange);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			this.mapCanvas = new UIComponent();
			this.fluxCanvas = new UIComponent();
			this.gridCanvas = new UIComponent();
			this.groundUnitCanvas = new UIComponent();
			this.convexHullCanvas = new UIComponent();
			this.airUnitCanvas = new UIComponent();
			
			this.mapCanvas.cacheAsBitmap = true;
			this.fluxCanvas.cacheAsBitmap = true;
			this.gridCanvas.cacheAsBitmap = true;
			
			this.addChild(mapCanvas);
			this.addChild(fluxCanvas);
			this.addChild(gridCanvas);
			this.addChild(groundUnitCanvas);
			this.addChild(convexHullCanvas);
			this.addChild(airUnitCanvas);
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
			drawFlux();
			drawMap();
			drawGridlines();
			drawUnits();
			drawConvexHulls();
			
			var o:DrawObject;
			for each (o in controller.currentState.getAirRobots()) {
				o.draw(true);
			}
			
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
			var flux:Array = controller.currentState.getFluxMatrix();
			var colorTransform:ColorTransform, scalar:uint;
			
			this.fluxCanvas.graphics.clear();
			for (i = 0; i < map.getHeight(); i++) {
				for (j = 0; j < map.getWidth(); j++) {
					tile = terrain[i][j] as TerrainTile;
					if (tile.getType() == TerrainTile.LAND) {
						scalar = (flux[i][j] / 64.0) * 0xFF;
						colorTransform = new ColorTransform(0, 0, 0 , 1, 0xFF - scalar, 0xCC, 0xFF - scalar, 0);
						this.fluxCanvas.graphics.beginFill(colorTransform.color, (scalar / 0xFF) * 0.5);
						this.fluxCanvas.graphics.drawRect(j * getGridSize(), i * getGridSize(), getGridSize(), getGridSize());
						this.fluxCanvas.graphics.endFill();
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
					this.gridCanvas.graphics.lineStyle(.5, 0x666666, 0.5);
					this.gridCanvas.graphics.drawRect(j * getGridSize(), i * getGridSize(), getGridSize(), getGridSize());
				}
			}
		}
		
		private function drawUnits():void {
			var loc:MapLocation, i:uint, j:uint, robot:DrawRobot;
			var groundRobots:Object = controller.currentState.getGroundRobots();
			var airRobots:Object = controller.currentState.getAirRobots();
			
			while (groundUnitCanvas.numChildren > 0)
				groundUnitCanvas.removeChildAt(0);
			
			while (airUnitCanvas.numChildren > 0)
				airUnitCanvas.removeChildAt(0);
			
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
			
			for each (robot in airRobots) {
				loc = robot.getLocation();
				j = (loc.getX() - origin.getX());
				i = (loc.getY() - origin.getY());
				robot.x = j * getGridSize() + getGridSize() / 2;
				robot.y = i * getGridSize() + getGridSize() / 2;
				robot.addEventListener(MouseEvent.CLICK, onRobotSelect, false, 0, true);
				airUnitCanvas.addChild(robot);
				robot.draw();
			}
		}
		
		private function drawConvexHulls():void {
			var locs:Array, loc:MapLocation;
			var x:uint, y:uint, i:uint;
			
			convexHullCanvas.graphics.clear();
			convexHullCanvas.graphics.lineStyle(2, 0xFF0000);
			convexHullCanvas.graphics.beginFill(0xFF0000, 0.1);
			for each (locs in controller.currentState.getConvexHulls(Team.A)) {
				// skip hulls with two or less
				if (locs.length <= 2)
					continue;
				// move to first point
				loc = locs[locs.length-1];
				x = (loc.getX() - origin.getX()) * getGridSize() + getGridSize() / 2;
				y = (loc.getY() - origin.getY()) * getGridSize() + getGridSize() / 2;
				convexHullCanvas.graphics.moveTo(x, y);
				// draw hull
				for (i = 0; i < locs.length; i++) {
					loc = locs[i];
					x = (loc.getX() - origin.getX()) * getGridSize() + getGridSize() / 2;
					y = (loc.getY() - origin.getY()) * getGridSize() + getGridSize() / 2;
					convexHullCanvas.graphics.lineTo(x, y);
				}
			}
			
			convexHullCanvas.graphics.lineStyle(2, 0x0000FF);
			convexHullCanvas.graphics.beginFill(0x0000FF, 0.1);
			for each (locs in controller.currentState.getConvexHulls(Team.B)) {
				// skip hulls with two or less
				if (locs.length <= 2)
					continue;
				// move to first point
				loc = locs[locs.length-1];
				x = (loc.getX() - origin.getX()) * getGridSize() + getGridSize() / 2;
				y = (loc.getY() - origin.getY()) * getGridSize() + getGridSize() / 2;
				convexHullCanvas.graphics.moveTo(x, y);
				// draw hull
				for (i = 0; i < locs.length; i++) {
					loc = locs[i];
					x = (loc.getX() - origin.getX()) * getGridSize() + getGridSize() / 2;
					y = (loc.getY() - origin.getY()) * getGridSize() + getGridSize() / 2;
					convexHullCanvas.graphics.lineTo(x, y);
				}
			}
		}
		
		private function updateUnits():void {
			var loc:MapLocation, i:uint, j:uint, robot:DrawRobot;
			var groundRobots:Object = controller.currentState.getGroundRobots();
			var airRobots:Object = controller.currentState.getAirRobots();
			
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
			
			for each (robot in airRobots) {
				loc = robot.getLocation();
				j = (loc.getX() - origin.getX());
				i = (loc.getY() - origin.getY());
				robot.x = j * getGridSize() + getGridSize() / 2;
				robot.y = i * getGridSize() + getGridSize() / 2;
				if (!robot.parent && robot.isAlive()) {
					robot.addEventListener(MouseEvent.CLICK, onRobotSelect, false, 0, true);
					airUnitCanvas.addChild(robot);
				}
				robot.draw();
			}
		}
		
		///////////////////////////////////////////////////////
		//////////////////// EVENT HANDLERS ///////////////////
		///////////////////////////////////////////////////////
		
		private function onEnterFrame(e:Event):void {
			gridCanvas.visible = RenderConfiguration.showGridlines();
			airUnitCanvas.visible = RenderConfiguration.showAir();
			groundUnitCanvas.visible = RenderConfiguration.showGround();
			convexHullCanvas.visible = RenderConfiguration.showConvexHulls();
			fluxCanvas.visible = RenderConfiguration.showFlux();
		}
		
		private function onRoundChange(e:MatchEvent):void {
			if (e.currentRound < lastRound) {
				drawUnits();
			}
			drawFlux();
			updateUnits();
			drawConvexHulls();
			
			lastRound = e.currentRound;
			
			this.visible = (e.currentRound != 0);
		}
		
		private function onMatchChange(e:MatchEvent):void {
			redrawAll();
			//this.visible = (e.currentRound != 0);
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