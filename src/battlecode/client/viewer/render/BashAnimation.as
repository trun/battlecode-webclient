package battlecode.client.viewer.render {
    import battlecode.common.Team;

    import mx.core.UIComponent;

    public class BashAnimation extends UIComponent implements DrawObject {
        private var isBashing:Boolean = false;
        private var team:String;

        private const BASH_FILL_A:uint = 0xFF0000;
        private const BASH_FILL_B:uint = 0x0000FF;
        private const BASH_LINE_A:uint = 0xFF6666;
        private const BASH_LINE_B:uint = 0x6666FF;

        public function BashAnimation(isBashing:Boolean, team:String) {
            this.isBashing = isBashing;
            this.team = team;
        }

        public function bash():void {
            isBashing = true;
        }

        public function draw(force:Boolean = false):void {
            this.graphics.clear();

            if (isBashing) {
                this.graphics.lineStyle(.5, team == Team.A ? BASH_LINE_A : BASH_LINE_B, 1);
                this.graphics.beginFill(team == Team.A ? BASH_FILL_A : BASH_FILL_B, 0.1);
                this.graphics.drawCircle(0, 0, 1.5 * RenderConfiguration.getGridSize());
            }
        }

        public function clone():DrawObject {
            return new BashAnimation(isBashing, team);
        }

        public function isAlive():Boolean {
            return true;
        }

        public function updateRound():void {
            isBashing = false;
        }

    }

}