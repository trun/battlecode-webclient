package battlecode.client.viewer.render {
    import mx.containers.Canvas;
    import mx.controls.Image;
    import mx.controls.Label;

    public class DrawHUDUnit extends Canvas {
        private var image:Image;
        private var countLabel:Label;
        private var type:String;
        private var team:String;

        public function DrawHUDUnit(type:String,  team:String) {
            width = 70;
            height = 25;

            horizontalScrollPolicy = "off";
            verticalScrollPolicy = "off";

            image = new Image();
            image.source = ImageAssets.getRobotAvatar(type, team);
            image.width = 25;
            image.height = 25;
            image.x = 0;
            image.y = 0;

            addChild(image);

            countLabel = new Label();
            countLabel.width = width - image.width - 5;
            countLabel.height = 30;
            countLabel.x = image.width + 5;
            countLabel.y = 2;
            countLabel.setStyle("color", 0xFFFFFF);
            countLabel.setStyle("fontSize", 18);
            countLabel.setStyle("fontWeight", "bold");
            countLabel.setStyle("textAlign", "center");
            countLabel.setStyle("fontFamily", "Courier New");
            countLabel.setStyle("textAlign", "left");
            countLabel.text = "00";

            addChild(countLabel);

            this.type = type;
            this.team = team;
        }

        public function setCount(count:int):void {
            countLabel.text = count.toString();
        }

        public function getType():String {
            return type;
        }

    }

}
