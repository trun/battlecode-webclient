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
import mx.controls.Spacer;
import mx.events.ResizeEvent;
    import mx.formatters.NumberFormatter;

    public class DrawHUD extends VBox {
        private var controller:MatchController;
        private var team:String;

        private var pointLabel:Label;
        private var archonBoxes:Object; // id -> DrawHUDArchon
        private var unitLabel:Label;
        private var unitBoxes:Array;
        private var winMarkerCanvas:Canvas;

        private var lastRound:uint = 0;
        private var maxArchons:uint = 0;

        private var formatter:NumberFormatter;

        public function DrawHUD(controller:MatchController, team:String) {
            this.controller = controller;
            this.team = team;

            controller.addEventListener(MatchEvent.ROUND_CHANGE, onRoundChange);
            controller.addEventListener(MatchEvent.MATCH_CHANGE, onMatchChange);
            addEventListener(ResizeEvent.RESIZE, onResize);

            width = 180;
            percentHeight = 100;
            autoLayout = false;

            horizontalScrollPolicy = "off";
            verticalScrollPolicy = "off";

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

            unitLabel = new Label();
            unitLabel.width = width;
            unitLabel.height = 30;
            unitLabel.setStyle("color", 0xFFFFFF);
            unitLabel.setStyle("fontSize", 18);
            unitLabel.setStyle("textAlign", "center");
            unitLabel.setStyle("fontFamily", "Courier New");
            unitLabel.text = "Units";
            addChild(unitLabel);

            archonBoxes = {};

            unitBoxes = new Array();
            for each (var unitType:String in RobotType.units()) {
                var unitBox:DrawHUDUnit = new DrawHUDUnit(unitType, team);
                unitBoxes.push(unitBox);
                addChild(unitBox);
            }

            formatter = new NumberFormatter();
            formatter.rounding = "down";
            formatter.precision = 0;

            addChild(winMarkerCanvas);

            repositionWinMarkers();
            drawArchonBoxes();
            drawUnitCounts();
        }

        private function onRoundChange(e:MatchEvent):void {
            var points:Number = controller.currentState.getPoints(team);
            pointLabel.text = formatter.format(points);

            if (e.currentRound <= lastRound) {
                drawWinMarkers();
            }
            lastRound = e.currentRound;

            var archons:Object = controller.currentState.getArchons(team);
            var archonCount:uint = 0;
            for each (var archon:DrawRobot in archons) {
                if (!archonBoxes[archon.getRobotID()]) {
                    archonBoxes[archon.getRobotID()] = new DrawHUDArchon();
                    addChild(archonBoxes[archon.getRobotID()]);
                }
                archonBoxes[archon.getRobotID()].setRobot(archon);
                archon.draw();
                archonCount++;
            }
            maxArchons = Math.max(maxArchons, archonCount);
            drawArchonBoxes();

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

            // clear archon boxes
            for (var a:String in archonBoxes) {
                archonBoxes[a].removeRobot();
                if (archonBoxes[a].parent == this) {
                    removeChild(archonBoxes[a]);
                }
            }
            archonBoxes = {};
            maxArchons = 0;

            drawWinMarkers();
        }

        private function drawArchonBoxes():void {
            var top:Number = 50;
            var i:uint = 0;
            for (var a:String in archonBoxes) {
                var archonBox:DrawHUDArchon = archonBoxes[a];
                archonBox.x = (width - archonBox.width * 3) / 2 + (i % 3) * archonBox.width;
                archonBox.y = ((archonBox.height + 10) * Math.floor(i / 3)) + top;
                i++;
            }
        }

        private function drawUnitCounts():void {
            var archonBoxTop:Number = Math.ceil(maxArchons / 3.0) * (DrawHUDArchon.HEIGHT + 10);
            var top:Number = archonBoxTop + 50;
            unitLabel.y = top + 10;
            top = unitLabel.height + unitLabel.y + 5;
            var i:uint = 0;
            for each (var unitBox:DrawHUDUnit in unitBoxes) {
                if (unitBox.getCount() > 0) {
                    unitBox.x = (width - unitBox.width * 3) / 2 + (i % 3) * unitBox.width;
                    unitBox.y = ((unitBox.height + 10) * Math.floor(i / 3)) + top;
                    unitBox.visible = true;
                    i++;
                } else {
                    unitBox.visible = false;
                }
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
            drawArchonBoxes();
            drawUnitCounts();
        }

    }

}