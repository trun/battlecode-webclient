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
        private var hqBox:DrawHUDHQ;
        private var towerBoxes:Object; // id -> DrawHUDTower
        private var buildingLabel:Label;
        private var buildingBoxes:Array;
        private var unitLabel:Label;
        private var unitBoxes:Array;
        private var winMarkerCanvas:Canvas;

        private var lastRound:uint = 0;
        private var maxTowers:uint = 0;

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

            hqBox = new DrawHUDHQ();
            addChild(hqBox);

            buildingLabel = new Label();
            buildingLabel.width = width;
            buildingLabel.height = 30;
            buildingLabel.setStyle("color", 0xFFFFFF);
            buildingLabel.setStyle("fontSize", 18);
            buildingLabel.setStyle("textAlign", "center");
            buildingLabel.setStyle("fontFamily", "Courier New");
            buildingLabel.text = "Buildings";
            addChild(buildingLabel);

            unitLabel = new Label();
            unitLabel.width = width;
            unitLabel.height = 30;
            unitLabel.setStyle("color", 0xFFFFFF);
            unitLabel.setStyle("fontSize", 18);
            unitLabel.setStyle("textAlign", "center");
            unitLabel.setStyle("fontFamily", "Courier New");
            unitLabel.text = "Units";
            addChild(unitLabel);

            towerBoxes = {};

            buildingBoxes = new Array();
            for each (var building:String in RobotType.buildings()) {
                var buildingBox:DrawHUDUnit = new DrawHUDUnit(building, team);
                buildingBoxes.push(buildingBox);
                addChild(buildingBox);
            }

            unitBoxes = new Array();
            for each (var unit:String in RobotType.units()) {
                var unitBox:DrawHUDUnit = new DrawHUDUnit(unit, team);
                unitBoxes.push(unitBox);
                addChild(unitBox);
            }

            formatter = new NumberFormatter();
            formatter.rounding = "down";
            formatter.precision = 0;

            addChild(winMarkerCanvas);

            repositionWinMarkers();
            resizeHQBox();
            drawTowerBoxes();
            drawBuildingCounts();
            drawUnitCounts();
        }

        private function onRoundChange(e:MatchEvent):void {
            var points:Number = controller.currentState.getPoints(team);
            pointLabel.text = formatter.format(points);

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

            var towers:Object = controller.currentState.getTowers(team);
            var towerCount:uint = 0;
            for each (var tower:DrawRobot in towers) {
                if (!towerBoxes[tower.getRobotID()]) {
                    towerBoxes[tower.getRobotID()] = new DrawHUDTower();
                    addChild(towerBoxes[tower.getRobotID()]);
                }
                towerBoxes[tower.getRobotID()].setRobot(tower);
                tower.draw();
                towerCount++;
            }
            maxTowers = Math.max(maxTowers, towerCount);
            drawTowerBoxes();

            for each (var buildingBox:DrawHUDUnit in buildingBoxes) {
                buildingBox.setCount(controller.currentState.getUnitCount(buildingBox.getType(), team));
            }
            drawBuildingCounts();

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

            // clear tower boxes
            for (var a:String in towerBoxes) {
                towerBoxes[a].removeRobot();
                if (towerBoxes[a].parent == this) {
                    removeChild(towerBoxes[a]);
                }
            }
            towerBoxes = {};
            maxTowers = 0;

            drawWinMarkers();
        }

        private function resizeHQBox():void {
            var boxSize:Number = Math.min(100, (height - 70 - pointLabel.height - winMarkerCanvas.height) - 20);
            hqBox.resize(boxSize);
            hqBox.x = (width - boxSize) / 2;
            hqBox.y = 50;
        }

        private function drawTowerBoxes():void {
            var top:Number = hqBox.height + hqBox.y + 10;
            var i:uint = 0;
            for (var a:String in towerBoxes) {
                var towerBox:DrawHUDTower = towerBoxes[a];
                towerBox.x = (width - towerBox.width * 3) / 2 + (i % 3) * towerBox.width;
                towerBox.y = ((towerBox.height + 10) * Math.floor(i / 3)) + top;
                i++;
            }
        }

        private function drawBuildingCounts():void {
            var towerBoxTop:Number = Math.ceil(maxTowers / 3.0) * (DrawHUDTower.HEIGHT + 10);
            var top:Number = hqBox.height + hqBox.y + towerBoxTop + 10;
            buildingLabel.y = top + 10;
            top = buildingLabel.height + buildingLabel.y + 5;
            var i:uint = 0;
            for each (var buildingBox:DrawHUDUnit in buildingBoxes) {
                buildingBox.x = (width - buildingBox.width * 3) / 2 + (i % 3) * buildingBox.width;
                buildingBox.y = ((buildingBox.height + 10) * Math.floor(i / 3)) + top;
                if (buildingBox.getCount() > 0) {
                    buildingBox.visible = true;
                    i++;
                } else {
                    buildingBox.visible = false;
                }
            }
        }

        private function drawUnitCounts():void {
            var topBuildingBox:DrawHUDUnit = buildingBoxes[buildingBoxes.length-1];
            for (var j:int = buildingBoxes.length - 1; j >= 0; j--) {
                topBuildingBox = buildingBoxes[j];
                if (topBuildingBox.visible) {
                    break;
                }
            }

            var top:Number = topBuildingBox.height + topBuildingBox.y + 10;
            unitLabel.y = top + 10;
            top = unitLabel.height + unitLabel.y + 5;
            var i:uint = 0;
            for each (var unitBox:DrawHUDUnit in unitBoxes) {
                unitBox.x = (width - unitBox.width * 3) / 2 + (i % 3) * unitBox.width;
                unitBox.y = ((unitBox.height + 10) * Math.floor(i / 3)) + top;
                if (unitBox.getCount() > 0) {
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
            resizeHQBox();
            drawTowerBoxes();
            drawBuildingCounts();
            drawUnitCounts();
        }

    }

}