package battlecode.client.viewer.render {
import battlecode.common.RobotType;

import mx.controls.Image;
    import mx.core.UIComponent;

    public class ExplosionAnimation extends UIComponent implements DrawObject {
        private var image:Image;
        private var robotType:String;
        private var round:int = 0;
        private var exploding:Boolean = false;

        public function ExplosionAnimation(robotType:String) {
            this.image = new Image();
            this.robotType = robotType;
            this.addChild(image);
        }

        public function explode():void {
            exploding = true;
        }

        public function draw(force:Boolean = false):void {
            if (!RenderConfiguration.showExplosions() || !exploding) {
                this.image.source = null;
                return;
            }

            // TODO big missile explosion animations?
            var w:Number = RenderConfiguration.getGridSize(); // * (robotType == RobotType.MISSILE ? 3 : 1);

            var imageSource:Class = getExplosionImage();
            this.image.source = new imageSource();
            this.image.width = w;
            this.image.height = w;
            this.image.x = -w / 2;
            this.image.y = -w / 2;
        }

        public function clone():DrawObject {
            var anim:ExplosionAnimation = new ExplosionAnimation(robotType);
            anim.round = round;
            anim.exploding = exploding;
            return anim;
        }

        public function getRound():uint {
            return round;
        }

        public function isExploding():Boolean {
            return exploding;
        }

        public function isAlive():Boolean {
            return round < 8 && exploding;
        }

        public function updateRound():void {
            if (exploding) round++;
        }

        private function getExplosionImage():Class {
            switch (round) {
                case 0:
                    return ImageAssets.EXPLODE_1;
                case 1:
                    return ImageAssets.EXPLODE_2;
                case 2:
                    return ImageAssets.EXPLODE_3;
                case 3:
                    return ImageAssets.EXPLODE_4;
                case 4:
                    return ImageAssets.EXPLODE_5;
                case 5:
                    return ImageAssets.EXPLODE_6;
                case 6:
                    return ImageAssets.EXPLODE_7;
                case 7:
                    return ImageAssets.EXPLODE_8;
                default:
                    return ImageAssets.EXPLODE_8;
            }
        }

    }

}