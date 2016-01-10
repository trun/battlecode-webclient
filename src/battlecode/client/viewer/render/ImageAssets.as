package battlecode.client.viewer.render {

    public class ImageAssets {
        // control bar background
        [Embed('/img/client/background.png')]
        public static const GRADIENT_BACKGROUND:Class;
        [Embed('/img/client/hud_unit_underlay.png')]
        public static const HUD_ARCHON_BACKGROUND:Class;

        // button icons
        [Embed('/img/client/icons/control_play.png')]
        public static const PLAY_ICON:Class;
        [Embed('/img/client/icons/control_pause.png')]
        public static const PAUSE_ICON:Class;
        [Embed('/img/client/icons/control_start.png')]
        public static const START_ICON:Class;
        [Embed('/img/client/icons/control_fastforward.png')]
        public static const FASTFORWARD_ICON:Class;
        [Embed('/img/client/icons/resultset_next.png')]
        public static const NEXT_ICON:Class;
        [Embed('/img/client/icons/resultset_previous.png')]
        public static const PREVIOUS_ICON:Class;
        [Embed('/img/client/icons/control_fastforward_blue.png')]
        public static const STEP_FORWARD_ICON:Class;
        [Embed('/img/client/icons/control_rewind_blue.png')]
        public static const STEP_BACKWARD_ICON:Class;
        [Embed('/img/client/icons/arrow_out.png')]
        public static const ENTER_FULLSCREEN_ICON:Class;
        [Embed('/img/client/icons/arrow_in.png')]
        public static const EXIT_FULLSCREEN_ICON:Class;
        [Embed('/img/client/icons/information.png')]
        public static const INFO_ICON:Class;

        // unit avatars
        [Embed('/img/units/archon0.png')]
        public static const ARCHON_A:Class;
        [Embed('/img/units/archon1.png')]
        public static const ARCHON_B:Class;
        [Embed('/img/units/archon2.png')]
        public static const ARCHON_NEUTRAL:Class;

        [Embed('/img/units/scout0.png')]
        public static const SCOUT_A:Class;
        [Embed('/img/units/scout1.png')]
        public static const SCOUT_B:Class;
        [Embed('/img/units/soldier0.png')]
        public static const SOLDIER_A:Class;
        [Embed('/img/units/soldier1.png')]
        public static const SOLDIER_B:Class;
        [Embed('/img/units/guard0.png')]
        public static const GUARD_A:Class;
        [Embed('/img/units/guard1.png')]
        public static const GUARD_B:Class;
        [Embed('/img/units/viper0.png')]
        public static const VIPER_A:Class;
        [Embed('/img/units/viper1.png')]
        public static const VIPER_B:Class;
        [Embed('/img/units/turret0.png')]
        public static const TURRET_A:Class;
        [Embed('/img/units/turret1.png')]
        public static const TURRET_B:Class;
        [Embed('/img/units/ttm0.png')]
        public static const TTM_A:Class;
        [Embed('/img/units/ttm1.png')]
        public static const TTM_B:Class;

        // zombie avatars
        [Embed('/img/units/zombieden3.png')]
        public static const ZOMBIEDEN_ZOMBIE:Class;
        [Embed('/img/units/standardzombie3.png')]
        public static const STANDARDZOMBIE_ZOMBIE:Class;
        [Embed('/img/units/rangedzombie3.png')]
        public static const RANGEDZOMBIE_ZOMBIE:Class;
        [Embed('/img/units/fastzombie3.png')]
        public static const FASTZOMBIE_ZOMBIE:Class;
        [Embed('/img/units/bigzombie3.png')]
        public static const BIGZOMBIE_ZOMBIE:Class;
        
        // explosions images
        [Embed('/img/explode/explode64_f01.png')]
        public static const EXPLODE_1:Class;
        [Embed('/img/explode/explode64_f02.png')]
        public static const EXPLODE_2:Class;
        [Embed('/img/explode/explode64_f03.png')]
        public static const EXPLODE_3:Class;
        [Embed('/img/explode/explode64_f04.png')]
        public static const EXPLODE_4:Class;
        [Embed('/img/explode/explode64_f05.png')]
        public static const EXPLODE_5:Class;
        [Embed('/img/explode/explode64_f06.png')]
        public static const EXPLODE_6:Class;
        [Embed('/img/explode/explode64_f07.png')]
        public static const EXPLODE_7:Class;
        [Embed('/img/explode/explode64_f08.png')]
        public static const EXPLODE_8:Class;

        [Embed('/img/hats/batman.png')]
        public static const HAT_BATMAN:Class;
        [Embed('/img/hats/bird.png')]
        public static const HAT_BIRD:Class;
        [Embed('/img/hats/bunny.png')]
        public static const HAT_BUNNY:Class;
        [Embed('/img/hats/christmas.png')]
        public static const HAT_CHRISTMAS:Class;
        [Embed('/img/hats/duck.png')]
        public static const HAT_DUCK:Class;
        [Embed('/img/hats/fedora.png')]
        public static const HAT_FEDORA:Class;
        [Embed('/img/hats/kipmud.png')]
        public static const HAT_KIPMUD:Class;
        [Embed('/img/hats/smiley.png')]
        public static const HAT_SMILEY:Class;

        public function ImageAssets() {
        }

        public static function getRobotAvatar(type:String, team:String):Class {
            return ImageAssets[type + "_" + team];
        }

        private static const HATS:Array = [ HAT_BATMAN, HAT_BIRD, HAT_BUNNY, HAT_CHRISTMAS, HAT_DUCK, HAT_FEDORA, HAT_KIPMUD, HAT_SMILEY ];

        public static function getHatAvatar(i:int):Class {
            return HATS[((i % HATS.length) + HATS.length) % HATS.length];
        }

    }

}