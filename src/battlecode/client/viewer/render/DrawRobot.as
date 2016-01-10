package battlecode.client.viewer.render {
    import battlecode.common.ActionType;
    import battlecode.common.Direction;
    import battlecode.common.MapLocation;
    import battlecode.common.RobotType;
    import battlecode.common.Team;
    import battlecode.events.RobotEvent;

    import flash.filters.GlowFilter;

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
        private var hatCanvas:UIComponent;
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
        private var alive:Boolean = true;
        private var hats:Array;
        private var hatImages:Array;
        private var zombieTurns:uint = 0;
        private var viperTurns:uint = 0;

        public function DrawRobot(robotID:uint, type:String, team:String, overrideSize:Number = 0) {
            this.robotID = robotID;
            this.type = type;
            this.team = team;
            this.maxEnergon = RobotType.maxEnergon(type);
            this.movementDelay = 1;
            this.hats = new Array();
            this.hatImages = new Array();

            this.actions = new Vector.<DrawAction>();

            this.overrideSize = overrideSize;

            // set the unit avatar image
            var avatarClass:Class = ImageAssets.getRobotAvatar(type, team);
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

            this.hatCanvas = new UIComponent();
            this.addChild(hatCanvas);

            // set the hit area for click selection
            this.hitArea = imageCanvas;

            // animations
            this.broadcastAnimation = new BroadcastAnimation(0, team);
            this.addChild(broadcastAnimation);

            this.explosionAnimation = new ExplosionAnimation(type);
            this.addChild(explosionAnimation);
        }

        public function clone():DrawObject {
            var d:DrawRobot = new DrawRobot(robotID, type, team, overrideSize);
            d.location = location;
            d.energon = energon;
            d.movementDelay = movementDelay;
            d.targetLocation = targetLocation;
            d.alive = alive;
            d.hats = hats.concat();
            d.hatImages = new Array();
            d.zombieTurns = zombieTurns;
            d.viperTurns = viperTurns;

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

        public function setZombieInfectedTurns(turns:uint):void {
            this.zombieTurns = turns;
        }

        public function setViperInfectedTurns(turns:uint):void {
            this.viperTurns = turns;
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
            this.explosionAnimation.setOverrideSize(overrideSize);
            this.draw(true);
        }

        public function attack(targetLocation:MapLocation):void {
            this.targetLocation = targetLocation;
            this.addAction(new DrawAction(ActionType.ATTACKING, RobotType.attackDelay(type)));
        }

        public function spawn(delay:uint):void {
            if (delay > 0) {
                this.addAction(new DrawAction(ActionType.SPAWNING, delay));
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

        public function wearHat(hat:int):void {
            hats.push(hat);
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

            // update tooltip
            this.toolTip = "Robot " + getRobotID() + " " + getType() + " Energon: " + energon + " Loc: " + getLocation().toString();
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
            //this.imageCanvas.rotation = directionToRotation(direction);

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
                    case ActionType.SPAWNING:
                        drawActionBar(o);
                        break;
                }
            }

            drawEnergonBar();
            drawSelected();
            drawHats();

            // add filters to show infections
            var filters:Array = [];
            if (viperTurns > 0) {
                filters.push(new GlowFilter(0xFF00FF, 1, 12, 12));
            } else if (zombieTurns > 0) {
                filters.push(new GlowFilter(0x00FF00, 1, 12, 12));
            }
            this.image.filters = filters;

            // draw animations
            broadcastAnimation.draw(force);
        }

        ///////////////////////////////////////////////////////
        ////////////// DRAWING HELPER FUNCTIONS ///////////////
        ///////////////////////////////////////////////////////

        private function drawEnergonBar():void {
            if (!RenderConfiguration.showEnergon() && getType() != RobotType.ARCHON)
                return;

            var ratio:Number = energon / maxEnergon;
            var color:uint;
            if (ratio > .5) {
                color = 0x00FF00;
            } else if (ratio > .25) {
                color = 0xFFFF00;
            } else {
                color = 0xFF0000;
            }

            var size:Number = getImageSize(true) * .9;
            this.graphics.lineStyle();
            this.graphics.beginFill(color, 0.8);
            this.graphics.drawRect(-size / 2, size / 2, ratio * size, 5 * getImageScale());
            this.graphics.endFill();
            this.graphics.beginFill(0x000000, 0.8);
            this.graphics.drawRect(-size / 2 + ratio * size, size / 2, (1 - ratio) * size, 5 * getImageScale());
            this.graphics.endFill();
            this.graphics.lineStyle(.5, 0xFFFFFF);
            this.graphics.drawRect(-size / 2, size / 2, size, 5 * getImageScale());
        }

        private function drawActionBar(action:DrawAction):void {
            var yOffset:Number = RenderConfiguration.showEnergon() ? 5 * getImageScale() : 0;
            var color:uint;
            switch (action.getType()) {
                case ActionType.SPAWNING:
                    color = 0x00FFFF;
                    break;
                default:
                    color = 0x000000;
                    break;
            }

            var ratio:Number = (action.getMaxRounds() - action.getRounds()) / action.getMaxRounds();
            var size:Number = getImageSize(true) * .9;
            this.graphics.lineStyle();
            this.graphics.beginFill(color, 0.8);
            this.graphics.drawRect(-size / 2, size / 2 + yOffset, ratio * size, 5 * getImageScale());
            this.graphics.endFill();
            this.graphics.beginFill(0x000000, 0.8);
            this.graphics.drawRect(-size / 2 + ratio * size, size / 2  + yOffset, (1 - ratio) * size, 5 * getImageScale());
            this.graphics.endFill();
            this.graphics.lineStyle(.5, 0xFFFFFF);
            this.graphics.drawRect(-size / 2, size / 2, size, 5 * getImageScale());
        }

        private function drawAttack():void {
            var targetOffsetX:Number = (targetLocation.getX() - location.getX()) * getImageSize();
            var targetOffsetY:Number = (targetLocation.getY() - location.getY()) * getImageSize();

            this.graphics.lineStyle(2, getAttackColor());
            this.graphics.moveTo(0, 0);
            this.graphics.lineTo(targetOffsetX - drawX, targetOffsetY - drawY);
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

        private function drawHats():void {
            if (!RenderConfiguration.showHats()) {
                hatCanvas.visible = false;
                return;
            }

            hatCanvas.visible = true;
            while (hatImages.length < hats.length) {
                var hatImage:Image = new Image();
                var hatSource:Class = ImageAssets.getHatAvatar(hats[hatImages.length]);
                hatImage.source = new hatSource();
                hatImage.width = RenderConfiguration.getGridSize();
                hatImage.height = RenderConfiguration.getGridSize();
                hatImage.x = -RenderConfiguration.getGridSize() / 2;
                hatImage.y = -RenderConfiguration.getGridSize() - hatImage.height * hatImages.length;
                hatCanvas.addChild(hatImage);
                hatImages.push(hatImage);
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

        private function getAttackColor():uint {
            switch (team) {
                case Team.A: return 0xFF0000;
                case Team.B: return 0x0000FF;
                case Team.ZOMBIE: return 0x33FF33;
            }
            return 0x000000;
        }

        private function getUnitScale(type:String):Number {
            switch (type) {
                case RobotType.ZOMBIEDEN:
                    return 0.75;
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
            if (RenderConfiguration.showDiscrete()) {
                return 0;
            }
            return -1 * getImageSize() * directionOffsetX(direction) * (rounds / movementDelay);
        }

        private function calculateDrawY(rounds:uint):Number {
            if (RenderConfiguration.showDiscrete()) {
                return 0;
            }
            return -1 * getImageSize() * directionOffsetY(direction) * (rounds / movementDelay);
        }


    }

}