package battlecode.client.viewer.render {
    import battlecode.common.ResearchType;

    import flash.utils.getTimer;

    import mx.containers.Canvas;
    import mx.controls.Image;

    public class DrawHUDResearch extends Canvas {
        private var image:Image;
        private var type:String;
        private var progress:Number;

        public function DrawHUDResearch(type:String) {
            width = 50;
            height = 50;

            horizontalScrollPolicy = "off";
            verticalScrollPolicy = "off";

            image = new Image();
            image.source = ResearchType.getImageAsset(type);
            image.width = 50;
            image.height = 50;
            image.x = 0;
            image.y = 0;

            progress = 0;
            this.type = type;

            addChild(image);
        }

        public function resize(size:Number):void {
            width = Math.max(size, 50);
            image.x = size - 50;
        }

        public function setProgress(val:Number):void {
            progress = val;
            draw();
        }

        public function getProgress():Number {
            return progress;
        }

        public function draw():void {
            if (progress == 0) {
                visible = false;
                return;
            }

            visible = true;
            this.graphics.clear();

            var color:uint = progress < 1.0 ? 0x00FFFF : 0x00FF00;
            if (progress < 1.0 && progress > 0.5
                    && type == ResearchType.NUKE && Math.floor(getTimer() / 400) % 2 == 0) {
                color = 0xFFFF66;
            }

            // draw progress bar
            var progressBarWidth:Number = width - image.width;
            this.graphics.lineStyle();
            this.graphics.beginFill(color, 0.8);
            this.graphics.drawRect(0, (height / 2) - 2.5, progress * progressBarWidth, 5);
            this.graphics.endFill();
            this.graphics.beginFill(0x000000, 0.8);
            this.graphics.drawRect(progress * progressBarWidth, (height / 2) - 2.5, (1 - progress) * progressBarWidth, 5);
            this.graphics.endFill();
        }

    }

}