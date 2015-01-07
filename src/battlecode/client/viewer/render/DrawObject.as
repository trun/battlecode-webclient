package battlecode.client.viewer.render {

    public interface DrawObject {

        function draw(force:Boolean = false):void;

        function clone():DrawObject;

        function isAlive():Boolean;

        function updateRound():void;

    }

}