package battlecode.client.viewer.render {
    import mx.containers.Canvas;
    import mx.controls.Image;

    public class DrawHUDHQ extends Canvas {
        private var image:Image;
        private var robot:DrawRobot;

        public function DrawHUDHQ() {
            width = 100;
            height = 100;

            horizontalScrollPolicy = "off";
            verticalScrollPolicy = "off";

            image = new Image();
            image.source = ImageAssets.HUD_ARCHON_BACKGROUND;
            image.width = width;
            image.height = height;
            image.x = 0;
            image.y = 0;

            addChild(image);
        }

        public function setRobot(o:DrawRobot):void {
            if (o != robot) {
                removeRobot();
                robot = o;
                robot.setOverrideSize(width * 0.7);
                o.x = width / 2;
                o.y = height / 2;
                addChild(o);
            }
        }

        public function removeRobot():void {
            if (robot && robot.parent == this)
                removeChild(robot);
        }

        public function resize(size:Number):void {
            width = image.width = size;
            height = image.height = size;
            if (robot) {
                robot.setOverrideSize(size * 0.7);
                robot.x = width / 2;
                robot.y = height / 2;
            }
        }

    }

}