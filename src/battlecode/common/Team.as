package battlecode.common {

    public class Team {

        public static const A:String = "A";
        public static const B:String = "B";
        public static const NEUTRAL:String = "NEUTRAL";
        public static const NONE:String = "NONE";
        public static const BOTH:String = "BOTH";

        public function Team() {
        }

        public static function cowColor(team:String):uint {
            switch (team) {
                case A:
                    return 0x990000;
                case B:
                    return 0x000099;
                case NONE:
                    return 0x009900;
                case BOTH:
                    return 0x009900;
                default:
                    return 0x999999;
            }
        }

        public static function opposite(team:String):String {
            switch (team) {
                case A:
                    return B;
                case B:
                    return A;
                default:
                    return null;
            }
        }

        public static function valueOf(value:int):String {
            switch (value) {
                case 0:
                    return NONE;
                case 1:
                    return A;
                case 2:
                    return B;
                case 3:
                    return BOTH;
            }
            throw new ArgumentError("Unknown team value: " + value);
        }

    }

}