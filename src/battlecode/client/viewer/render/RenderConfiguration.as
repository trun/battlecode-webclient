package battlecode.client.viewer.render {
    import flash.net.SharedObject;

    public class RenderConfiguration {
        public static const GRID_SIZE:Number = 32.0;
        private static var scale:Number = 1.0;

        private static var broadcast:Boolean = false;
        private static var discrete:Boolean = false;
        private static var energon:Boolean = true;
        private static var gridlines:Boolean = true;
        private static var rubble:Boolean = true;
        private static var parts:Boolean = true;
        private static var hats:Boolean = true;
        private static var explosions:Boolean = true;
        private static var ground:Boolean = true;
        private static var zombies:Boolean = true;
        private static var tournament:Boolean = false;
        private static var scaleToFit:Boolean = true;
        private static var minimap:Boolean = true;

        public function RenderConfiguration() {
        }

        public static function loadConfiguration():void {
            try {
                var so:SharedObject = SharedObject.getLocal("webclient-settings");
                var s:Object = so.data.settings;
                broadcast = s.broadcast != null ? s.broadcast : broadcast;
                discrete = s.discrete != null ? s.discrete : discrete;
                energon = s.energon != null ? s.energon : energon;
                gridlines = s.gridlines != null ? s.gridlines : gridlines;
                rubble = s.rubble != null ? s.rubble : rubble;
                parts = s.parts != null ? s.parts : parts;
                explosions = s.explosions != null ? s.explosions : explosions;
                minimap = s.minimap != null ? s.minimap : minimap;
            } catch (e:Error) {
                trace("Could not load settings from SharedObject: " + e.toString());
            }
        }

        public static function saveConfiguration():void {
            try {
                var so:SharedObject = SharedObject.getLocal("webclient-settings");
                var settings:Object = {
                    broadcast: broadcast,
                    discrete: discrete,
                    energon: energon,
                    gridlines: gridlines,
                    rubble: rubble,
                    parts: parts,
                    explosions: explosions,
                    minimap: minimap
                };
                so.data.settings = settings;
                so.flush();
            } catch (e:Error) {
                trace("Could not save settings to SharedObject: " + e.toString());
            }
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

        public static function showZombies():Boolean {
            return zombies;
        }

        public static function showRubble():Boolean {
            return rubble;
        }

        public static function showParts():Boolean {
            return parts;
        }

        public static function showHats():Boolean {
            return hats;
        }

        public static function showMinimap():Boolean {
            return minimap;
        }

        public static function isScaleToFit():Boolean {
            return scaleToFit;
        }

        public static function isTournament():Boolean {
            return tournament;
        }

        public static function toggleBroadcast():void {
            broadcast = !broadcast;
            saveConfiguration();
        }

        public static function toggleDiscrete():void {
            discrete = !discrete;
            saveConfiguration();
        }

        public static function toggleEnergon():void {
            energon = !energon;
            saveConfiguration();
        }

        public static function toggleGridlines():void {
            gridlines = !gridlines;
            saveConfiguration();
        }

        public static function toggleExplosions():void {
            explosions = !explosions;
            saveConfiguration();
        }

        public static function toggleRubble():void {
            rubble = !rubble;
            saveConfiguration();
        }

        public static function toggleParts():void {
            parts = !parts;
            saveConfiguration();
        }

        public static function toggleHats():void {
            hats = !hats;
        }

        public static function toggleScaleToFit():void {
            scaleToFit = !scaleToFit;
            saveConfiguration();
        }

        public static function toggleMinimap():void {
            minimap = !minimap;
            saveConfiguration();
        }

        public static function toggleDrawHeight():void {
            if (!zombies && !ground) {
                ground = true;
                zombies = true;
            } else if(ground && !zombies) {
                ground = false;
                zombies = true;
            } else if(zombies && !ground) {
                ground = false;
                zombies = false;
            } else {
                ground = true;
                zombies = false;
            }
        }

    }

}