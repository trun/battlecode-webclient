package battlecode.common {
    public class AttackType {
        public static const NORMAL:String = "NORMAL";
        public static const LIGHT:String = "LIGHT";

        public static function fromType(attackType:uint):String {
            return attackType == 0 ? NORMAL : LIGHT;
        }

        public function AttackType() {
        }
    }
}
