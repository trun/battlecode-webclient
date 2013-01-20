package battlecode.common {

    public class Team {

        public static const A:String = "A";
        public static const B:String = "B";
        public static const NEUTRAL:String = "NEUTRAL";

        public function Team() {
        }

        public static function mineColor(team:String):uint {
            switch (team) {
                case A:
                    return 0xFF6666;
                case B:
                    return 0x6666FF;
                default:
                    return 0x999999;
            }
        }

    }

}