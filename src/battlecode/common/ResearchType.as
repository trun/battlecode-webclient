package battlecode.common {
    import battlecode.client.viewer.render.ImageAssets;

    public class ResearchType {
        public static const FUSION:String = "FUSION";
        public static const VISION:String = "VISION";
        public static const DEFUSION:String = "DEFUSION";
        public static const PIXAXE:String = "PIXAXE";
        public static const NUKE:String = "NUKE";

        public function ResearchType() {
        }

        public static function values():Array {
            return [ FUSION, VISION, DEFUSION, PIXAXE, NUKE ];
        }

        public static function getField(type:String):int {
            return values().indexOf(type);
        }

        public static function getImageAsset(type:String):Class {
            return ImageAssets["RESEARCH_" + type];
        }
    }

}