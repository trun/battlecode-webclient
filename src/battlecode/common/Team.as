package battlecode.common {

    public class Team {

        public static const A:String = "A";
        public static const B:String = "B";
        public static const NEUTRAL:String = "NEUTRAL";
        public static const ZOMBIE:String = "ZOMBIE";
        public static const NONE:String = "NONE";
        public static const BOTH:String = "BOTH";

        public function Team() {
        }

        public static function isPlayer(team:String):Boolean {
            return team == A || team == B;
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