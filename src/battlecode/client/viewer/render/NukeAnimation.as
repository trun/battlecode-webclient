package battlecode.client.viewer.render {
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import mx.controls.Image;
    import mx.core.UIComponent;

    public class NukeAnimation extends UIComponent implements DrawObject {
        private var image:Image;
        private var round:int = 0;
        private var exploding:Boolean = false;

        private var timer:Timer;

        public function NukeAnimation() {
            this.image = new Image();
            this.addChild(image);

            timer = new Timer(60, 60);
            timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                round++;
                draw();
            });
        }

        public function explode():void {
            exploding = true;
            timer.start();
        }

        public function draw(force:Boolean = false):void {
            var imageSource:Class = getExplosionImage();
            if (imageSource) {
                image.source = new imageSource();
                image.width = RenderConfiguration.getGridSize() * 4;
                image.height = RenderConfiguration.getGridSize() * 2;
                image.x = -(image.width / 2);
                image.y = -(image.height / 2);
            } else {
                image.source = null;
            }
        }

        public function clone():DrawObject {
            var anim:NukeAnimation = new NukeAnimation();
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
            return round < 12 && exploding;
        }

        public function updateRound():void {
            // updated via timer
        }

        private function getExplosionImage():Class {
            if (round < 12) {
                return ImageAssets["NUKE_" + (round+1)];
            }
            return null;
        }

    }

}