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

        // unit avatars
        [Embed('/img/units/hq1.png')]
        public static const HQ_A:Class;
        [Embed('/img/units/hq2.png')]
        public static const HQ_B:Class;
        [Embed('/img/units/soldier1.png')]
        public static const SOLDIER_A:Class;
        [Embed('/img/units/soldier2.png')]
        public static const SOLDIER_B:Class;
        [Embed('/img/units/noisetower1.png')]
        public static const NOISETOWER_A:Class;
        [Embed('/img/units/noisetower2.png')]
        public static const NOISETOWER_B:Class;
        [Embed('/img/units/pastr1.png')]
        public static const PASTR_A:Class;
        [Embed('/img/units/pastr2.png')]
        public static const PASTR_B:Class;

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