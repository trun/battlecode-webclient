package battlecode.client.viewer.render {

    import battlecode.client.viewer.MatchController;
    import battlecode.common.RobotType;
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
        private var hqBox:DrawHUDHQ;
        private var researchBoxes:Array;
        private var unitBoxes:Array;
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

            hqBox = new DrawHUDHQ();
            addChild(hqBox);

            unitBoxes = new Array();
            for each (var unit:String in RobotType.ground()) {
                var unitBox:DrawHUDUnit = new DrawHUDUnit(unit, team);
                unitBoxes.push(unitBox);
                addChild(unitBox);
            }

            addChild(winMarkerCanvas);

            repositionWinMarkers();
            resizeHQBox();
            drawResearchBoxes();
            drawUnitCounts();
        }

        private function onRoundChange(e:MatchEvent):void {
            pointLabel.text = String(controller.currentState.getFlux(team));

            if (e.currentRound <= lastRound) {
                hqBox.removeRobot();
                drawWinMarkers();
            }
            lastRound = e.currentRound;

            var hq:DrawRobot = controller.currentState.getHQ(team);
            if (hq && hq.isAlive()) {
                hqBox.setRobot(hq);
                hq.draw();
            }

            for each (var unitBox:DrawHUDUnit in unitBoxes) {
                unitBox.setCount(controller.currentState.getUnitCount(unitBox.getType(), team));
            }
            drawUnitCounts();

            if (controller.currentRound == controller.match.getRounds()) {
                drawWinMarkers();
            }
        }

        private function onMatchChange(e:MatchEvent):void {
            pointLabel.text = "0";
            hqBox.removeRobot();
            drawWinMarkers();
            drawResearchBoxes();
        }

        private function resizeHQBox():void {
            var boxSize:Number = Math.min(100, (height - 70 - pointLabel.height - winMarkerCanvas.height) - 20);
            hqBox.resize(boxSize);
            hqBox.x = (180 - boxSize) / 2;
            hqBox.y = 50;
        }

        private function drawResearchBoxes():void {
            var i:uint = 0;
            var bottomUnitBox:DrawHUDUnit = unitBoxes[unitBoxes.length - 1];
            var top:Number = bottomUnitBox.y + bottomUnitBox.height + 10;
        }

        private function drawUnitCounts():void {
            var top:Number = hqBox.height + hqBox.y + 10;
            var i:uint = 0;
            for each (var unitBox:DrawHUDUnit in unitBoxes) {
                unitBox.x = (180 - unitBox.width * 3) / 2 + (i % 3) * unitBox.width;
                unitBox.y = ((unitBox.height + 10) * Math.floor(i / 3)) + top;
                i++;
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
            resizeHQBox();
            drawResearchBoxes();
            drawUnitCounts();
        }

    }

}