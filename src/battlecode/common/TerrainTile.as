package battlecode.common {

    public class TerrainTile {
        private var type:String;

        public static const LAND:String = "LAND";
        public static const VOID:String = "VOID";

        public function TerrainTile(type:String) {
            this.type = type;
        }

        public function getType():String {
            return type;
        }
    }

}