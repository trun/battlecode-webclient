package battlecode.serial {
    import battlecode.common.GameConstants;
    import battlecode.common.RobotType;

    public class StoredConstantsLoader {
        public function StoredConstantsLoader() {
        }

        public static function loadConstants(xml:XML):void {
            loadGameConstants(xml.child("gameConstants"));
            loadRobotTypes(xml.child("robotTypes"));
        }

        private static function loadGameConstants(gameConstants:XMLList):void {
            for each (var entry:XML in gameConstants.children()) {
                var name:String = entry.children()[0].text();
                var valueNode:XML = entry.children()[1];
                switch (valueNode.name().toString()) {
                    case "int":
                        GameConstants.setValue(name, parseInt(valueNode.text()));
                        break;
                    case "double":
                        GameConstants.setValue(name, parseFloat(valueNode.text()));
                        break;
                }
            }
        }

        private static function loadRobotTypes(robotTypes:XMLList):void {
            for each (var entry:XML in robotTypes.children()) {
                var robotType:String = entry.children()[0].text();
                var entries:XMLList = entry.children()[1].children();
                RobotType.setValues(robotType, parseRobotType(entries));
            }
        }

        private static function parseRobotType(entries:XMLList):Object {
            var constants:Object = {};
            for each (var entry:XML in entries) {
                var name:String = entry.children()[0].text();
                var valueNode:XML = entry.children()[1];
                switch (valueNode.name().toString()) {
                    case "int":
                        constants[name] = parseInt(valueNode.text());
                        break;
                    case "double":
                        constants[name] = parseFloat(valueNode.text());
                        break;
                    case "boolean":
                        constants[name] = ParseUtils.parseBoolean(valueNode.text());
                        break;
                }
            }
            return constants;
        }
    }
}
