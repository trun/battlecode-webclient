package battlecode.client.viewer.render {
    import mx.containers.Canvas;
    import mx.controls.Image;

    public class DrawHUDArchon extends Canvas {
        private var image:Image;
        private var archon:DrawRobot;

        public function DrawHUDArchon() {
            width = 75;
            height = 75;

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

        public function setArchon(o:DrawRobot):void {
            if (o != archon) {
                removeArchon();
                archon = o;
                archon.setOverrideSize(width * 0.6);
                o.x = width / 2;
                o.y = height / 2;
                addChild(o);
            }
        }

        public function removeArchon():void {
            if (archon && archon.parent == this)
                removeChild(archon);
        }

        public function resize(size:Number):void {
            width = image.width = size;
            height = image.height = size;
            if (archon) {
                archon.setOverrideSize(size * 0.55);
                archon.x = width / 2;
                archon.y = height / 2;
            }
        }

    }

}