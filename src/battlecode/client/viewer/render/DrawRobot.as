package battlecode.client.viewer.render {
	import battlecode.common.ActionType;
	import battlecode.common.AuraType;
	import battlecode.common.Direction;
	import battlecode.common.GameConstants;
	import battlecode.common.MapLocation;
	import battlecode.common.RobotType;
	import battlecode.common.Team;
	import battlecode.events.RobotEvent;
	import flash.display.Sprite;
	import flash.utils.getTimer;
	import mx.containers.Box;
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.core.BitmapAsset;
	import mx.core.UIComponent;
	
	[Event(name="indicatorStringChange", type="battlecode.events.RobotEvent")]
	public class DrawRobot extends Canvas implements DrawObject {
		
		private var actions:Vector.<DrawAction>;
		
		private var broadcastAnimation:BroadcastAnimation;
		private var explosionAnimation:ExplosionAnimation;
		
		private var overlayCanvas:UIComponent;
		private var imageCanvas:UIComponent;
		private var image:Image;
		
		// size
		private var overrideSize:Number;
		
		// indicator strings
		private var indicatorStrings:Vector.<String> = new Vector.<String>(3, true);
		
		// movement animation
		private var drawX:Number, drawY:Number;
		private var forwards:Boolean = false;
		private var movementDelay:uint;
		
		// attack animation
		private var targetLocation:MapLocation;
		private var targetLevel:String
		
		// transfer animation
		private var transferLocation:MapLocation;
		private var isTransferring:Boolean = false;
		
		private var selected:Boolean = false;
		
		private var robotID:uint;
		private var type:String;
		private var team:String;
		private var location:MapLocation;
		private var direction:String;
		private var energon:Number = 0;
		private var maxEnergon:Number = 0;
		private var flux:Number = 0;
		private var maxFlux:Number = 0;
		private var aura:String;
		private var alive:Boolean = true;
		
		public function DrawRobot(robotID:uint, type:String, team:String, overrideSize:Number=0) {
			this.robotID = robotID;
			this.type = type;
			this.team = team;
			this.maxEnergon = RobotType.maxEnergon(type);
			this.maxFlux = RobotType.maxFlux(type);
			
			this.actions = new Vector.<DrawAction>();
			
			this.overrideSize = overrideSize;
			
			// set the unit avatar image
			var avatarClass:Class = getUnitAvatar(type, team);
			this.imageCanvas = new UIComponent();
			this.image = new Image();
			this.image.source = avatarClass;
			this.image.width = getImageSize(true);
			this.image.height = getImageSize(true);
			this.image.x = -this.image.width/2;
			this.image.y = -this.image.height/2;
			this.imageCanvas.addChild(image);
			this.addChild(imageCanvas);
			
			this.width = this.image.width;
			this.height = this.image.height;
			
			this.overlayCanvas = new UIComponent();
			this.addChild(overlayCanvas);
			
			// set the hit area for click selection
			this.hitArea = imageCanvas;
			
			// animations
			this.broadcastAnimation = new BroadcastAnimation(0, team);
			this.addChild(broadcastAnimation);
			
			this.explosionAnimation = new ExplosionAnimation();
			this.addChild(explosionAnimation);
		}
		
		public function clone():DrawObject {
			var d:DrawRobot = new DrawRobot(robotID, type, team, overrideSize);
			d.location = location;
			d.direction = direction;
			d.energon = energon;
			d.flux = flux;
			d.forwards = forwards;
			d.movementDelay = movementDelay;
			d.targetLocation = targetLocation;
			d.targetLevel = targetLevel;
			d.aura = aura;
			d.alive = alive;
			
			d.actions = new Vector.<DrawAction>(actions.length);
			for each (var o:DrawAction in actions) {
				d.actions.push(o.clone());
			}
			
			d.removeChild(d.broadcastAnimation);
			d.removeChild(d.explosionAnimation);
			d.broadcastAnimation = broadcastAnimation.clone() as BroadcastAnimation;
			d.explosionAnimation = explosionAnimation.clone() as ExplosionAnimation;
			d.addChild(d.broadcastAnimation);
			d.addChild(d.explosionAnimation);
			
			return d;
		}
		
		private function addAction(d:DrawAction):void {
			actions.push(d);
		}
		
		public function getRobotID():uint { return robotID; }
		public function getType():String { return type; }
		public function getTeam():String { return team; }
		public function getLocation():MapLocation { return location; }
		public function getEnergon():Number { return energon; }
		public function getFlux():Number { return flux; }
		public function getSelected():Boolean { return selected; }
		public function getIndicatorString(index:uint):String {
			return indicatorStrings[index];
		}
		
		public function setDirection(direction:String):void {
			this.direction = direction;
		}
		
		public function setLocation(location:MapLocation):void {
			this.location = location;
		}
		
		public function setEnergon(amt:Number):void {
			this.energon = Math.min(Math.max(0, amt), maxEnergon);
		}
		
		public function setFlux(amt:Number):void {
			this.flux = Math.min(Math.max(0, amt), maxFlux);
		}
		
		public function setAura(aura:String):void {
			this.aura = aura;
		}
		
		public function setSelected(val:Boolean):void {
			this.selected = val;
		}
		
		public function setIndicatorString(str:String, index:uint):void {
			indicatorStrings[index] = str;
			dispatchEvent(new RobotEvent(RobotEvent.INDICATOR_STRING_CHANGE, false, false, this));
		}
		
		public function setOverrideSize(overrideSize:Number):void {
			this.overrideSize = overrideSize;
			this.draw(true);
		}
		
		public function attack(targetLocation:MapLocation):void {
			this.targetLocation = targetLocation;
			this.addAction(new DrawAction(ActionType.ATTACKING, RobotType.attackDelay(type)));
		}
		
		public function broadcast():void {
			this.broadcastAnimation.broadcast();
		}
		
		public function evolve(type:String):void {
			this.type = type;
			this.maxEnergon = RobotType.maxEnergon(type);
			this.image.source = getUnitAvatar(type, team);
			this.image.width = getImageSize(true);
			this.image.height = getImageSize(true);
			this.image.x = -this.image.width/2;
			this.image.y = -this.image.height/2;
			this.addAction(new DrawAction(ActionType.TRANSFORMING, RobotType.wakeDelay(type)));
		}
		
		public function destroyUnit():void {
			this.explosionAnimation.explode();
			this.alive = false;
		}
		
		public function drain():void {
			this.addAction(new DrawAction(ActionType.DRAINING, 1));
		}
		
		public function transferEnergon(target:MapLocation, level:String, amount:Number):void {
			if (!this.isTransferring) {
				this.transferLocation = target;
				this.isTransferring = true;
				this.addAction(new DrawAction(ActionType.TRANSFERRING, 10));
			}
		}
		
		public function transferFlux(target:MapLocation, level:String, amount:Number):void {
			if (!this.isTransferring) {
				this.transferLocation = target;
				this.isTransferring = true;
				this.addAction(new DrawAction(ActionType.TRANSFERRING, 10));
			}
		}
		
		public function moveToLocation(location:MapLocation):void {
			this.movementDelay = Direction.isDiagonal(direction) ?
									RobotType.movementDelayDiagonal(type) :
									RobotType.movementDelay(type);
			this.location = location;
			this.addAction(new DrawAction(ActionType.MOVING, movementDelay));
		}
		
		public function isAlive():Boolean {
			return alive || explosionAnimation.isAlive();
		}
		
		public function updateRound():void {
			// update actions
			for (var i:uint = 0; i < actions.length; i++) {
				var o:DrawAction = actions[i];
				o.decreaseRound();
				if (o.getRounds() <= 0) {
					actions.splice(i, 1);
					i--;
					// special case for transfers
					if (o.getType() == ActionType.TRANSFERRING)
						this.isTransferring = false;
				}
			}
			
			// clear aura
			aura = null;
			
			// update animations
			broadcastAnimation.updateRound();
			explosionAnimation.updateRound();
		}
		
		public function draw(force:Boolean = false):void {
			if (explosionAnimation.isExploding()) {
				this.imageCanvas.visible = false;
				this.overlayCanvas.visible = false;
				this.graphics.clear();
				
				explosionAnimation.draw(force);
				return;
			}
			
			// draw direction
			this.imageCanvas.rotation = directionToRotation(direction);
			
			if (force) {
				this.image.width = getImageSize(true);
				this.image.height = getImageSize(true);
				this.image.x = -this.image.width/2;
				this.image.y = -this.image.height/2;
			}
			
			// clear the graphics object once
			this.graphics.clear();
			this.overlayCanvas.graphics.clear();
			
			var o:DrawAction;
			var movementRounds:uint = 0;
			for each (o in actions) {
				if (o.getType() == ActionType.MOVING) {
					movementRounds = o.getRounds();
					break;
				}
			}
			
			drawX = calculateDrawX(movementRounds); drawY = calculateDrawY(movementRounds);
			
			for each (o in actions) {
				switch (o.getType()) {
					case ActionType.ATTACKING:
						drawAttack();
						break;
					case ActionType.MOVING:
						drawMovement();
						break;
					case ActionType.TRANSFORMING:
						break;
					case ActionType.TRANSFERRING:
						drawTransferBar(o.getRounds() / 5);
						break;
				}
			}
			
			drawAura();
			drawEnergonBar();
			drawSelected();
			
			// draw animations
			broadcastAnimation.draw(force);
		}
		
		///////////////////////////////////////////////////////
		////////////// DRAWING HELPER FUNCTIONS ///////////////
		///////////////////////////////////////////////////////
		
		private function drawEnergonBar():void {
			if (!RenderConfiguration.showEnergon())
				return;
			
			var ratio:Number = RobotType.isBuilding(type) ? (flux / maxFlux) : (energon / maxEnergon);
			var size:Number = getImageSize();
			this.graphics.lineStyle();
			this.graphics.beginFill(0x00FF00, 0.8);
			this.graphics.drawRect(-size/2, size/2, ratio*size, 5*getImageScale());
			this.graphics.endFill();
			this.graphics.beginFill(0x000000, 0.8);
			this.graphics.drawRect(-size/2 + ratio*size, size/2, (1 - ratio) * size, 5*getImageScale());
			this.graphics.endFill();
		}
		
		private function drawTransferBar(alpha:Number):void {
			if (!RenderConfiguration.showTransfers())
				return;
			
			var targetOffsetX:Number = (transferLocation.getX() - location.getX()) * getImageSize();
			var targetOffsetY:Number = (transferLocation.getY() - location.getY()) * getImageSize();
			
			this.overlayCanvas.graphics.lineStyle(2, 0x00FF00, alpha);
			this.overlayCanvas.graphics.moveTo(0, 0);
			this.overlayCanvas.graphics.lineTo(targetOffsetX - drawX, targetOffsetY - drawY);
		}
		
		private function drawAttack():void {
			var targetOffsetX:Number = (targetLocation.getX() - location.getX()) * getImageSize();
			var targetOffsetY:Number = (targetLocation.getY() - location.getY()) * getImageSize();
			
			this.graphics.lineStyle(2, team == Team.A ? 0xFF0000 : 0x0000FF);
			this.graphics.moveTo(0, 0);
			this.graphics.lineTo(targetOffsetX - drawX, targetOffsetY - drawY);
			this.graphics.drawCircle(targetOffsetX - drawX, targetOffsetY - drawY, getImageSize() / 2 * .6);
		}
		
		private function drawMovement():void {
			if (RenderConfiguration.showDiscrete()) return;
			
			this.x += drawX;
			this.y += drawY;
		}
		
		private function drawAura():void {
			if (!aura)
				return;
			this.graphics.lineStyle();
			if (aura == AuraType.OFF) {
				this.graphics.beginFill(0xFFB345, 0.58);
			} else if (aura == AuraType.DEF) {
				this.graphics.beginFill(0x003DF5, 0.58);
			} else if (aura == AuraType.MOV) {
				this.graphics.beginFill(0x00F53D, 0.58);
			}
			this.graphics.drawCircle(0, 0, RobotType.sensorRadius(type) * getImageSize());
			this.graphics.endFill();
		}
		
		private function drawSelected():void {
			var size:Number = getImageSize();
			
			if (selected) {
				this.graphics.lineStyle(2, 0xFFFFFF);
				this.graphics.drawRect(-size / 2, -size / 2, size, size);
			}
		}
		
		///////////////////////////////////////////////////////
		////////////// PRIVATE HELPER FUNCTIONS ///////////////
		///////////////////////////////////////////////////////
		
		private function getImageSize(scale:Boolean=false):Number {
			if (overrideSize)
				return overrideSize;
			return RenderConfiguration.getGridSize() * (scale ? getUnitScale(type) : 1.0);
		}
		
		private function getImageScale():Number {
			if (overrideSize)
				return 1.0;
			return RenderConfiguration.getScalingFactor();
		}
		
		private function getUnitAvatar(type:String, team:String):Class {
			switch(type) {
				case RobotType.ARCHON:
					return (team == Team.A) ? ImageAssets.ARCHON_A : ImageAssets.ARCHON_B;
				case RobotType.CHAINER:
					return (team == Team.A) ? ImageAssets.CHAINER_A : ImageAssets.CHAINER_B;
				case RobotType.TURRET:
					return (team == Team.A) ? ImageAssets.TURRET_A : ImageAssets.TURRET_B;
				case RobotType.SOLDIER:
					return (team == Team.A) ? ImageAssets.SOLDIER_A : ImageAssets.SOLDIER_B;
				case RobotType.WOUT:
					return (team == Team.A) ? ImageAssets.WOUT_A : ImageAssets.WOUT_B;
				case RobotType.AURA:
					return (team == Team.A) ? ImageAssets.AURA_A : ImageAssets.AURA_B;
				case RobotType.COMM:
					return (team == Team.A) ? ImageAssets.COMM_A : ImageAssets.COMM_B;
				case RobotType.TELEPORTER:
					return (team == Team.A) ? ImageAssets.TELEPORTER_A : ImageAssets.TELEPORTER_B;
			}
			return null;
		}
		
		private function getUnitScale(type:String):Number {
			switch(type) {
				case RobotType.ARCHON: return 1.2;
				case RobotType.CHAINER: return .9;
				case RobotType.SOLDIER: return .9;
				case RobotType.WOUT: return .8;
				case RobotType.TELEPORTER: return .8;
				case RobotType.AURA: return .8;
				case RobotType.COMM: return .8;
				default: return 1.0;
			}
		}
		
		private function getUnitOffset(type:String):Number {
			return (RobotType.isAirborne(type)) ? -5 * getImageScale() : 0;
		}
		
		private function directionToRotation(dir:String):int {
			switch (dir) {
				case Direction.NORTH: return -90;
				case Direction.NORTH_EAST: return -45;
				case Direction.EAST: return 0;
				case Direction.SOUTH_EAST: return 45;
				case Direction.SOUTH: return 90;
				case Direction.SOUTH_WEST: return 135;
				case Direction.WEST: return 180;
				case Direction.NORTH_WEST: return -135;
				default: return 0;
			}
		}
		
		private function directionOffsetX(dir:String):int {
			switch (dir) {
				case Direction.NORTH_EAST: return +1;
				case Direction.NORTH_WEST: return -1;
				case Direction.SOUTH_EAST: return +1;
				case Direction.SOUTH_WEST: return -1;
				case Direction.NORTH: return 0;
				case Direction.SOUTH: return 0;
				case Direction.EAST: return +1;
				case Direction.WEST: return -1;
				default: return 0;
			}
		}
		
		private function directionOffsetY(dir:String):int {
			switch (dir) {
				case Direction.NORTH_EAST: return -1;
				case Direction.NORTH_WEST: return -1;
				case Direction.SOUTH_EAST: return +1;
				case Direction.SOUTH_WEST: return +1;
				case Direction.NORTH: return -1;
				case Direction.SOUTH: return +1;
				case Direction.EAST: return 0;
				case Direction.WEST: return 0;
				default: return 0;
			}
		}
		
		private function calculateDrawX(rounds:uint):Number {
			if (RenderConfiguration.showDiscrete()) return 0;
			
			var dir:String = (forwards) ? Direction.opposite(direction) : direction;
			return getImageSize() * directionOffsetX(dir) * (rounds / movementDelay);
		}
		
		private function calculateDrawY(rounds:uint):Number {
			if (RenderConfiguration.showDiscrete()) return 0;
			
			var dir:String = (forwards) ? Direction.opposite(direction) : direction;
			return getImageSize() * directionOffsetY(dir) * (rounds / movementDelay);
		}
		
		
	}
	
}