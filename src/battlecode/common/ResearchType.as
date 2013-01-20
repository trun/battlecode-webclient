package battlecode.common {
    import battlecode.client.viewer.render.ImageAssets;

    public class ResearchType {
        public static const PIXAXE:String = "PIXAXE";
        public static const DEFUSION:String = "DEFUSION";
        public static const VISION:String = "VISION";
        public static const FUSION:String = "FUSION";
        public static const NUKE:String = "NUKE";

        public function ResearchType() {
        }

        public static function getField(type:String):int {
            switch (type) {
                case PIXAXE: return 0;
                case DEFUSION: return 1;
                case VISION: return 2;
                case FUSION: return 3;
                case NUKE: return 4;
            }
            return -1;
        }

        public static function getImageAsset(type:String):Class {
            return ImageAssets["RESEARCH_" + type];
        }
    }

}