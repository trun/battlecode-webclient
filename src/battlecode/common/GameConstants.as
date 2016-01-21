package battlecode.common {

    public class GameConstants {
        public function GameConstants() {
        }

        private static var constants:Object = {};

        public static function getValue(name:String):* {
            return constants[name];
        }

        public static function setValue(name:String, value:*):void {
            constants[name] = value;
        }
    }

}