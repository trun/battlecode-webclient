package battlecode.client.viewer.render {
    import mx.containers.Canvas;
    import mx.controls.Image;
    import mx.controls.Label;

    public class DrawHUDUnit extends Canvas {
        private var image:Image;
        private var countLabel:Label;
        private var type:String;
        private var team:String;

        public function DrawHUDUnit(type:String, team:String) {
            width = 35;
            height = 60;

            horizontalScrollPolicy = "off";
            verticalScrollPolicy = "off";

            image = new Image();
            image.source = ImageAssets.getRobotAvatar(type, team);
            image.width = 25;
            image.height = 25;
            image.x = 5;
            image.y = 0;
            image.toolTip = type;

            addChild(image);

            countLabel = new Label();
            countLabel.width = width;
            countLabel.height = 30;
            countLabel.x = 0;
            countLabel.y = image.height + 5;
            countLabel.setStyle("color", 0xFFFFFF);
            countLabel.setStyle("fontSize", 18);
            countLabel.setStyle("fontWeight", "bold");
            countLabel.setStyle("textAlign", "center");
            countLabel.setStyle("fontFamily", "Courier New");
            countLabel.text = "00";

            addChild(countLabel);

            this.type = type;
            this.team = team;
        }

        public function setCount(count:int):void {
            countLabel.text = count.toString();
        }

        public function getCount():int {
            return parseInt(countLabel.text);
        }
        public function getType():String {
            return type;
        }

    }

}
