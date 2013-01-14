package battlecode.client.viewer.render {
    import battlecode.common.Team;

    import mx.core.UIComponent;

    public class BroadcastAnimation extends UIComponent implements DrawObject {
        private var broadcasts:uint = 0;
        private var team:String;

        private const BROADCAST_MASK:uint = 0xFFFFFF;
        private const BROADCAST_COLOR_A:uint = 0xFF6666;
        private const BROADCAST_COLOR_B:uint = 0x6666FF;

        public function BroadcastAnimation(broadcasts:uint, team:String) {
            this.broadcasts = broadcasts;
            this.team = team;
        }

        public function broadcast():void {
            broadcasts++;
        }

        public function draw(force:Boolean = false):void {
            this.graphics.clear();

            if (!RenderConfiguration.showBroadcast()) return;
            for (var i:uint = 0; i < 24; i++) {
                if (broadcasts & (1 << i)) {
                    this.graphics.lineStyle(.5 - (i / 12), (team == Team.A) ? BROADCAST_COLOR_A : BROADCAST_COLOR_B, (24 - i) / 24);
                    this.graphics.drawCircle(0, 0, i * 4 * RenderConfiguration.getScalingFactor());
                }
            }
        }

        public function clone():DrawObject {
            return new BroadcastAnimation(broadcasts, team);
        }

        public function isAlive():Boolean {
            return true;
        }

        public function updateRound():void {
            broadcasts = (broadcasts << 1) & BROADCAST_MASK;
        }

    }

}