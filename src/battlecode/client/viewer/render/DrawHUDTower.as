package battlecode.client.viewer.render {
    import mx.containers.Canvas;
    import mx.controls.Image;

    public class DrawHUDTower extends Canvas {
        public static const HEIGHT:Number = 35;

        private var image:Image;
        private var robot:DrawRobot;

        public function DrawHUDTower() {
            width = 35;
            height = HEIGHT;

            horizontalScrollPolicy = "off";
            verticalScrollPolicy = "off";
        }

        public function setRobot(o:DrawRobot):void {
            if (o != robot) {
                removeRobot();
                robot = o;
                robot.setOverrideSize(25);
                robot.x = width / 2;
                robot.y = height / 2;
                addChild(robot);
            }
        }

        public function getRobot():DrawRobot {
            return robot;
        }

        public function removeRobot():void {
            if (robot && robot.parent == this)
                removeChild(robot);
        }

        public function resize(size:Number):void {
            width = image.width = size;
            height = image.height = size;
            if (robot) {
                robot.setOverrideSize(size);
                robot.x = width / 2;
                robot.y = height / 2;
            }
        }

    }

}