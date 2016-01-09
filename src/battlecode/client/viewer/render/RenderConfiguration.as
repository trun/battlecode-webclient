package battlecode.client.viewer.render {

    public class RenderConfiguration {
        public static const GRID_SIZE:Number = 32.0;
        private static var scale:Number = 1.0;

        private static var broadcast:Boolean = false;
        private static var discrete:Boolean = false;
        private static var energon:Boolean = true;
        private static var gridlines:Boolean = false;
        private static var ore:Boolean = true;
        private static var hats:Boolean = true;
        private static var explosions:Boolean = true;
        private static var ground:Boolean = true;
        private static var air:Boolean = true;
        private static var tournament:Boolean = false;

        public function RenderConfiguration() {
        }

        public static function setScalingFactor(val:Number):void {
            scale = val;
        }

        public static function getScalingFactor():Number {
            return scale;
        }

        public static function getGridSize():Number {
            return GRID_SIZE * scale;
        }

        public static function setTournamentMode(val:Boolean):void {
            tournament = val;
        }

        public static function showBroadcast():Boolean {
            return broadcast;
        }

        public static function showDiscrete():Boolean {
            return discrete;
        }

        public static function showEnergon():Boolean {
            return energon;
        }

        public static function showGridlines():Boolean {
            return gridlines;
        }

        public static function showExplosions():Boolean {
            return explosions;
        }

        public static function showGround():Boolean {
            return ground;
        }

        public static function showAir():Boolean {
            return air;
        }

        public static function showRubble():Boolean {
            return ore;
        }

        public static function showHats():Boolean {
            return hats;
        }

        public static function isTournament():Boolean {
            return tournament;
        }

        public static function toggleBroadcast():void {
            broadcast = !broadcast;
        }

        public static function toggleDiscrete():void {
            discrete = !discrete;
        }

        public static function toggleEnergon():void {
            energon = !energon;
        }

        public static function toggleGridlines():void {
            gridlines = !gridlines;
        }

        public static function toggleExplosions():void {
            explosions = !explosions;
        }

        public static function toggleOre():void {
            ore = !ore;
        }

        public static function toggleHats():void {
            hats = !hats;
        }

        public static function toggleDrawHeight():void {
            if (!air && !ground) {
                ground = true;
                air = true;
            } else if(ground && !air) {
                ground = false;
                air = true;
            } else if(air && !ground) {
                ground = false;
                air = false;
            } else {
                ground = true;
                air = false;
            }
        }

    }

}