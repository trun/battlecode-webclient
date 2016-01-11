package battlecode.events {
    import flash.events.Event;

    public class MiniMapEvent extends Event {
        public static const UPDATE_VIEWER:String = "updateViewer";

        private var viewerXPercent:Number;
        private var viewerYPercent:Number;

        public function MiniMapEvent(type:String, viewerXPercent:Number, viewerYPercent:Number, bubbles:Boolean = false, cancelable:Boolean = false) {
            super(type, bubbles, cancelable);
            this.viewerXPercent = viewerXPercent;
            this.viewerYPercent = viewerYPercent;
        }

        public function getViewerXPercent():Number {
            return viewerXPercent;
        }

        public function getViewerYPercent():Number {
            return viewerYPercent;
        }

        public override function clone():Event {
            return new MiniMapEvent(type, viewerXPercent, viewerYPercent, bubbles, cancelable);
        }

        public override function toString():String {
            return formatToString("MiniMapEvent", "type", "bubbles", "cancelable", "eventPhase", "viewerX", "viewerY");
        }

    }

}