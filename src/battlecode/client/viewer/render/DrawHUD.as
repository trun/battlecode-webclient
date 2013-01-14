package battlecode.client.viewer.render {

    import battlecode.client.viewer.MatchController;
    import battlecode.common.Team;
    import battlecode.events.MatchEvent;
    import battlecode.serial.Match;

    import flash.filters.DropShadowFilter;

    import mx.containers.Canvas;
    import mx.containers.VBox;
    import mx.controls.Label;
    import mx.events.ResizeEvent;

    public class DrawHUD extends VBox {
        private var controller:MatchController;
        private var team:String;

        private var pointLabel:Label;
        private var archonBoxes:Array; // DrawArchonHUD[]
        private var winMarkerCanvas:Canvas;

        private var lastRound:uint = 0;

        public function DrawHUD(controller:MatchController, team:String) {
            this.controller = controller;
            this.team = team;

            controller.addEventListener(MatchEvent.ROUND_CHANGE, onRoundChange);
            controller.addEventListener(MatchEvent.MATCH_CHANGE, onMatchChange);
            addEventListener(ResizeEvent.RESIZE, onResize);

            width = 180;
            percentHeight = 100;
            autoLayout = false;

            pointLabel = new Label();
            pointLabel.width = width;
            pointLabel.height = 30;
            pointLabel.x = 0;
            pointLabel.y = 10;
            pointLabel.filters = [ new DropShadowFilter(3, 45, 0x333333, 1, 2, 2) ];
            pointLabel.setStyle("color", team == Team.A ? 0xFF6666 : 0x9999FF);
            pointLabel.setStyle("fontSize", 24);
            pointLabel.setStyle("fontWeight", "bold");
            pointLabel.setStyle("textAlign", "center");
            pointLabel.setStyle("fontFamily", "Courier New");

            winMarkerCanvas = new Canvas();
            winMarkerCanvas.width = width;
            winMarkerCanvas.height = 40;

            addChild(pointLabel);

            archonBoxes = new Array();
            for (var i:uint = 0; i < 6; i++) {
                var archonBox:DrawHUDArchon = new DrawHUDArchon();
                archonBoxes.push(archonBox);
                addChild(archonBox);
            }

            addChild(winMarkerCanvas);

            repositionWinMarkers();
            resizeArchonBoxes();
        }

        private function onRoundChange(e:MatchEvent):void {
            pointLabel.text = String(controller.currentState.getPoints(team));

            if (e.currentRound <= lastRound) {
                for each (var archonBox:DrawHUDArchon in archonBoxes) {
                    archonBox.removeArchon();
                }
                drawWinMarkers();
            }
            lastRound = e.currentRound;

            /*
             var archons:Array = controller.currentState.getArchons(team);
             var box:uint = 0, i:uint;
             for (i = 0; i < archons.length; i++) {
             if (archons[i].isAlive()) {
             archonBoxes[box++].setArchon(archons[i]);
             archons[i].draw();
             }
             }
             for (i = box; i < archonBoxes.length; i++) {
             archonBoxes[i].removeArchon();
             }
             */

            if (controller.currentRound == controller.match.getRounds())
                drawWinMarkers();
        }

        private function onMatchChange(e:MatchEvent):void {
            pointLabel.text = "0";
            for each (var archonBox:DrawHUDArchon in archonBoxes) {
                archonBox.removeArchon();
            }
            drawWinMarkers();
        }

        private function resizeArchonBoxes():void {
            var boxSize:Number = Math.min(75, (height - 70 - pointLabel.height - winMarkerCanvas.height) / 6 - 20);
            for (var i:uint = 0; i < 6; i++) {
                archonBoxes[i].resize(boxSize);
                archonBoxes[i].x = (180 - boxSize) / 2;
                archonBoxes[i].y = ((boxSize + 20) * i) + 50;
            }
        }

        private function drawWinMarkers():void {
            var matches:Vector.<Match> = controller.getMatches();
            winMarkerCanvas.graphics.clear();
            var i:uint, wins:uint = 0;
            var numMatches:int =
                    (controller.currentRound == controller.match.getRounds()) ?
                            controller.currentMatch :
                            controller.currentMatch - 1;
            for (i = 0; i <= numMatches; i++) {
                if (matches[i].getWinner() == team) {
                    var x:Number = (winMarkerCanvas.height - 5) / 2 + wins * winMarkerCanvas.height + 30;
                    var y:Number = (winMarkerCanvas.height - 5) / 2;
                    var r:Number = (winMarkerCanvas.height - 5) / 2;
                    winMarkerCanvas.graphics.lineStyle(2, 0x000000);
                    winMarkerCanvas.graphics.beginFill((team == Team.A) ? 0xFF6666 : 0x9999FF);
                    winMarkerCanvas.graphics.drawCircle(x, y, r);
                    winMarkerCanvas.graphics.endFill();
                    wins++;
                }
            }
        }

        private function repositionWinMarkers():void {
            winMarkerCanvas.y = height - winMarkerCanvas.height - 20;
        }

        private function onResize(e:ResizeEvent):void {
            repositionWinMarkers();
            resizeArchonBoxes();
        }

    }

}