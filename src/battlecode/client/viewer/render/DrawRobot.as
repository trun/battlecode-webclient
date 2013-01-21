package battlecode.client.viewer.render {
    import battlecode.common.ActionType;
    import battlecode.common.Direction;
    import battlecode.common.GameConstants;
    import battlecode.common.MapLocation;
    import battlecode.common.RobotType;
    import battlecode.common.Team;
    import battlecode.events.RobotEvent;

    import mx.containers.Canvas;
    import mx.controls.Image;
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
        private var movementDelay:uint;

        // attack animation
        private var targetLocation:MapLocation;

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
        private var alive:Boolean = true;

        public function DrawRobot(robotID:uint, type:String, team:String, overrideSize:Number = 0) {
            this.robotID = robotID;
            this.type = type;
            this.team = team;
            this.maxEnergon = RobotType.maxEnergon(type);
            this.movementDelay = 0;

            this.actions = new Vector.<DrawAction>();

            this.overrideSize = overrideSize;

            // set the unit avatar image
            var avatarClass:Class = getUnitAvatar(type, team);
            this.imageCanvas = new UIComponent();
            this.image = new Image();
            this.image.source = avatarClass;
            this.image.width = getImageSize(true);
            this.image.height = getImageSize(true);
            this.image.x = -this.image.width / 2;
            this.image.y = -this.image.height / 2;
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
            d.energon = energon;
            d.movementDelay = movementDelay;
            d.targetLocation = targetLocation;
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

        public function getRobotID():uint {
            return robotID;
        }

        public function getType():String {
            return type;
        }

        public function getTeam():String {
            return team;
        }

        public function getLocation():MapLocation {
            return location;
        }

        public function getSelected():Boolean {
            return selected;
        }

        public function getIndicatorString(index:uint):String {
            return indicatorStrings[index];
        }

        public function setLocation(location:MapLocation):void {
            this.location = location;
        }

        public function setEnergon(amt:Number):void {
            this.energon = Math.min(Math.max(0, amt), maxEnergon);
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

        public function capture():void {
            this.addAction(new DrawAction(ActionType.CAPTURING, GameConstants.CAPTURE_DELAY));
        }

        public function layMine():void {
            this.addAction(new DrawAction(ActionType.MINING, GameConstants.MINE_LAY_DELAY));
        }

        public function stopLayingMine():void {
            this.addAction(new DrawAction(ActionType.MINING_STOPPING, GameConstants.MINE_LAY_STOP_DELAY));
        }

        public function diffuseMine(hasUpgrade:Boolean):void {
            this.addAction(new DrawAction(ActionType.DEFUSING, hasUpgrade ? GameConstants.MINE_DIFFUSE_UPGRADE_DELAY: GameConstants.MINE_DIFFUSE_DELAY))
        }

        public function attack(targetLocation:MapLocation):void {
            if (type == RobotType.ARTILLERY) {
                this.targetLocation = targetLocation;
                this.addAction(new DrawAction(ActionType.ATTACKING, RobotType.attackDelay(type)));
            }
        }

        public function broadcast():void {
            this.broadcastAnimation.broadcast();
        }

        public function destroyUnit():void {
            this.explosionAnimation.explode();
            this.alive = false;
        }

        public function moveToLocation(location:MapLocation):void {
            this.direction = this.location.directionTo(location);
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
                }
            }

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
                this.image.x = -this.image.width / 2;
                this.image.y = -this.image.height / 2;
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

            drawX = calculateDrawX(movementRounds);
            drawY = calculateDrawY(movementRounds);

            for each (o in actions) {
                switch (o.getType()) {
                    case ActionType.ATTACKING:
                        drawAttack();
                        break;
                    case ActionType.MOVING:
                        drawMovement();
                        break;
                    case ActionType.CAPTURING:
                    case ActionType.MINING:
                    case ActionType.MINING_STOPPING:
                    case ActionType.DEFUSING:
                        drawActionBar(o);
                        break;
                }
            }

            drawEnergonBar();
            drawSelected();

            // draw animations
            broadcastAnimation.draw(force);
        }

        ///////////////////////////////////////////////////////
        ////////////// DRAWING HELPER FUNCTIONS ///////////////
        ///////////////////////////////////////////////////////

        private function drawEnergonBar():void {
            if (!RenderConfiguration.showEnergon() && getType() != RobotType.HQ)
                return;

            if (getType() == RobotType.ENCAMPMENT)
                return;

            var ratio:Number = energon / maxEnergon;
            var size:Number = getImageSize(true);
            this.graphics.lineStyle();
            this.graphics.beginFill(0x00FF00, 0.8);
            this.graphics.drawRect(-size / 2, size / 2, ratio * size, 5 * getImageScale());
            this.graphics.endFill();
            this.graphics.beginFill(0x000000, 0.8);
            this.graphics.drawRect(-size / 2 + ratio * size, size / 2, (1 - ratio) * size, 5 * getImageScale());
            this.graphics.endFill();
        }

        private function drawActionBar(action:DrawAction):void {
            var yOffset:Number = RenderConfiguration.showEnergon() ? 5 * getImageScale() : 0;
            var color:uint;
            switch (action.getType()) {
                case ActionType.CAPTURING:
                    color = 0x4C4CFF;
                    break;
                case ActionType.MINING:
                    color = 0xFF00CC;
                    break;
                case ActionType.MINING_STOPPING:
                    color = 0xFF0000;
                    break;
                case ActionType.DEFUSING:
                    color = 0x00FFFF;
                    break;
                default:
                    color = 0x000000;
                    break;
            }

            var ratio:Number;
            switch (action.getType()) {
                case ActionType.MINING_STOPPING:
                    ratio = action.getRounds() / action.getMaxRounds();
                    break;
                default:
                    ratio = (action.getMaxRounds() - action.getRounds()) / action.getMaxRounds();
                    break;
            }
            var size:Number = getImageSize(true);
            this.graphics.lineStyle();
            this.graphics.beginFill(color, 0.8);
            this.graphics.drawRect(-size / 2, size / 2 + yOffset, ratio * size, 5 * getImageScale());
            this.graphics.endFill();
            this.graphics.beginFill(0x000000, 0.8);
            this.graphics.drawRect(-size / 2 + ratio * size, size / 2  + yOffset, (1 - ratio) * size, 5 * getImageScale());
            this.graphics.endFill();
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

        private function drawSelected():void {
            var size:Number = getImageSize(true);

            if (selected) {
                this.graphics.lineStyle(2, 0xFFFFFF);
                this.graphics.moveTo(-size / 2, -size / 4);
                this.graphics.lineTo(-size / 2, -size / 2);
                this.graphics.lineTo(-size / 4, -size / 2);
                this.graphics.moveTo(size / 2, -size / 4);
                this.graphics.lineTo(size / 2, -size / 2);
                this.graphics.lineTo(size / 4, -size / 2);
                this.graphics.moveTo(size / 2, size / 4);
                this.graphics.lineTo(size / 2, size / 2);
                this.graphics.lineTo(size / 4, size / 2);
                this.graphics.moveTo(-size / 2, size / 4);
                this.graphics.lineTo(-size / 2, size / 2);
                this.graphics.lineTo(-size / 4, size / 2);
            }
        }

        ///////////////////////////////////////////////////////
        ////////////// PRIVATE HELPER FUNCTIONS ///////////////
        ///////////////////////////////////////////////////////

        private function getImageSize(scale:Boolean = false):Number {
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
            return ImageAssets[type + "_" + team];
        }

        private function getUnitScale(type:String):Number {
            switch (type) {
                case RobotType.HQ:
                    return 2.0;
                default:
                    return 1.0;
            }
        }

        private function getUnitOffset(type:String):Number {
            return 0;
        }

        private function directionToRotation(dir:String):int {
            switch (dir) {
                case Direction.NORTH:
                    return -90;
                case Direction.NORTH_EAST:
                    return -45;
                case Direction.EAST:
                    return 0;
                case Direction.SOUTH_EAST:
                    return 45;
                case Direction.SOUTH:
                    return 90;
                case Direction.SOUTH_WEST:
                    return 135;
                case Direction.WEST:
                    return 180;
                case Direction.NORTH_WEST:
                    return -135;
                default:
                    return 0;
            }
        }

        private function directionOffsetX(dir:String):int {
            switch (dir) {
                case Direction.NORTH_EAST:
                    return +1;
                case Direction.NORTH_WEST:
                    return -1;
                case Direction.SOUTH_EAST:
                    return +1;
                case Direction.SOUTH_WEST:
                    return -1;
                case Direction.NORTH:
                    return 0;
                case Direction.SOUTH:
                    return 0;
                case Direction.EAST:
                    return +1;
                case Direction.WEST:
                    return -1;
                default:
                    return 0;
            }
        }

        private function directionOffsetY(dir:String):int {
            switch (dir) {
                case Direction.NORTH_EAST:
                    return -1;
                case Direction.NORTH_WEST:
                    return -1;
                case Direction.SOUTH_EAST:
                    return +1;
                case Direction.SOUTH_WEST:
                    return +1;
                case Direction.NORTH:
                    return -1;
                case Direction.SOUTH:
                    return +1;
                case Direction.EAST:
                    return 0;
                case Direction.WEST:
                    return 0;
                default:
                    return 0;
            }
        }

        private function calculateDrawX(rounds:uint):Number {
            return 0;
        }

        private function calculateDrawY(rounds:uint):Number {
            return 0;
        }


    }

}