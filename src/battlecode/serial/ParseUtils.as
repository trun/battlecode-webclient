package battlecode.serial {
    import battlecode.common.MapLocation;

    public class ParseUtils {
        private static const whitespace:Array = [ "\n", "\r", "\t" ];

        public function ParseUtils() {
        }

        public static function parseLocation(str:String):MapLocation {
            var coordinates:Array = str.split(",");
            return new MapLocation(coordinates[0], coordinates[1]);
        }

        public static function parseNumber(str:String):Number {
            if (str.indexOf("E") != -1) {
                var valAndExp:Array = str.split("E");
                return parseFloat(valAndExp[0]) * Math.pow(10, valAndExp[1]);
            }
            return parseFloat(str);
        }

        public static function parseBoolean(str:String):Boolean {
            return str == "true";
        }

        public static function trim(str:String):String {
            while (whitespace.indexOf(str.charAt(0)) != -1)
                str = str.substring(1);
            while (whitespace.indexOf(str.charAt(str.length - 1)) != -1)
                str = str.substring(0, str.length - 1);
            return str;
        }

        public static function unencode(str:String):String {
            str = replaceAll("&lt;", "<", str);
            str = replaceAll("&gt;", ">", str);
            str = replaceAll("&quot;", "\"", str);
            str = replaceAll("&#039;", "\'", str);
            str = replaceAll("&amp;", "&", str);
            return str;
        }

        private static function replaceAll(pattern:String, repl:String, str:String):String {
            var i:int = str.indexOf(pattern);
            while (i != -1) {
                str = str.replace(pattern, repl);
                i = str.indexOf(pattern);
            }
            return str;
        }
    }

}