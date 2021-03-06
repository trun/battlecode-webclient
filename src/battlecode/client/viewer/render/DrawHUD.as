﻿package battlecode.client.viewer.render {
    import battlecode.client.viewer.MatchController;
    import battlecode.common.RobotType;
    import battlecode.common.Team;
    import battlecode.events.MatchEvent;
    import battlecode.serial.Match;

    import flash.events.Event;

    import flash.filters.DropShadowFilter;

    import mx.containers.Canvas;
    import mx.containers.HBox;
    import mx.containers.VBox;
    import mx.controls.Label;
    import mx.events.ResizeEvent;

    public class DrawHUD extends VBox {
        private var controller:MatchController;
        private var team:String;

        private var teamNameBox:HBox;
        private var teamNameLabel:Label;
        private var pointsLabel:Label;
        private var winMarkerCanvas:Canvas;
        private var pointsCanvas:Canvas;
        private var archonBoxes:Object; // id -> DrawHUDArchon
        private var unitBoxes:Array;
        private var maxArchons:uint = 0;

        public function DrawHUD(controller:MatchController, team:String) {
            this.controller = controller;
            this.team = team;

            controller.addEventListener(MatchEvent.ROUND_CHANGE, onRoundChange);
            controller.addEventListener(MatchEvent.MATCH_CHANGE, onMatchChange);
            addEventListener(ResizeEvent.RESIZE, onResize);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);

            width = 250;
            height = 150;
            autoLayout = false;

            horizontalScrollPolicy = "off";
            verticalScrollPolicy = "off";

            teamNameBox = new HBox();
            teamNameBox.horizontalScrollPolicy = "off";
            teamNameBox.verticalScrollPolicy = "off";
            teamNameBox.autoLayout = false;
            teamNameBox.width = width - 10;
            teamNameBox.height = 40;
            teamNameBox.x = 5;
            teamNameBox.y = 5;
            teamNameBox.setStyle("backgroundColor", team == Team.A ? 0xFF6666 : 0x9999FF);
            addChild(teamNameBox);

            teamNameLabel = new Label();
            teamNameLabel.width = teamNameBox.width - 60;
            teamNameLabel.height = teamNameBox.height - 10;
            teamNameLabel.x = 5;
            teamNameLabel.y = 5;
            teamNameLabel.filters = [ new DropShadowFilter(3, 45, 0x333333, 1, 2, 2) ];
            teamNameLabel.truncateToFit = false;
            teamNameLabel.setStyle("color", 0xFFFFFF);
            teamNameLabel.setStyle("fontSize", 24);
            teamNameLabel.setStyle("fontWeight", "bold");
            teamNameLabel.setStyle("textAlign", "left");
            teamNameLabel.setStyle("fontFamily", "Courier New");
            teamNameBox.addChild(teamNameLabel);

            winMarkerCanvas = new Canvas();
            winMarkerCanvas.width = teamNameBox.width;
            winMarkerCanvas.height = teamNameBox.height;
            teamNameBox.addChild(winMarkerCanvas);

            pointsCanvas = new Canvas();
            pointsCanvas.width = teamNameBox.width;
            pointsCanvas.height = teamNameBox.height;
            teamNameBox.addChild(pointsCanvas);

            pointsLabel = new Label();
            pointsLabel.width = 80;
            pointsLabel.height = 30;
            pointsLabel.x = 165;
            pointsLabel.y = teamNameBox.height + teamNameBox.y + 5;
            pointsLabel.toolTip = "Total Army Value + Spare Parts";
            pointsLabel.filters = [ new DropShadowFilter(3, 45, 0x333333, 1, 2, 2) ];
            pointsLabel.truncateToFit = false;
            pointsLabel.setStyle("color", team == Team.A ? 0xFF6666 : 0x9999FF);
            pointsLabel.setStyle("fontSize", 24);
            pointsLabel.setStyle("fontWeight", "bold");
            pointsLabel.setStyle("textAlign", "right");
            pointsLabel.setStyle("fontFamily", "Courier New");
            addChild(pointsLabel);

            archonBoxes = {};

            unitBoxes = [];
            for each (var unitType:String in RobotType.units()) {
                var unitBox:DrawHUDUnit = new DrawHUDUnit(unitType, team);
                unitBoxes.push(unitBox);
                addChild(unitBox);
            }

            drawArchonBoxes();
            drawUnitCounts();
        }

        private function onEnterFrame(e:Event):void {
            pointsLabel.visible = RenderConfiguration.showHUDPointLabel();
            pointsCanvas.visible = RenderConfiguration.showHUDPointBar();
        }

        private function onRoundChange(e:MatchEvent):void {
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

            for each (var unitBox:DrawHUDUnit in unitBoxes) {
                unitBox.setCount(controller.currentState.getUnitCount(unitBox.getType(), team));
            }

            drawArchonBoxes();
            drawUnitCounts();
            drawPointsBar();

            if (controller.currentRound == controller.match.getRounds()) {
                drawWinMarkers();
            }
        }

        private function onMatchChange(e:MatchEvent):void {
            var nameA:String = controller.match.getNameA() || controller.match.getTeamA();
            var nameB:String = controller.match.getNameB() || controller.match.getTeamB();
            teamNameLabel.text = team == Team.A ? nameA : nameB;
            if (teamNameLabel.text.length <= 7) {
                teamNameLabel.setStyle("fontSize", 24);
                teamNameLabel.y = 5;
            } else if (teamNameLabel.text.length <= 10) {
                teamNameLabel.setStyle("fontSize", 20);
                teamNameLabel.y = 7;
            } else {
                if (teamNameLabel.text.length > 18) {
                    teamNameLabel.toolTip = teamNameLabel.text;
                    teamNameLabel.text = teamNameLabel.text.substring(0, 17) + "\u2026";
                }
                teamNameLabel.setStyle("fontSize", 16);
                teamNameLabel.y = 10;
            }

            // clear archon boxes
            for (var a:String in archonBoxes) {
                archonBoxes[a].removeRobot();
                if (archonBoxes[a].parent == this) {
                    removeChild(archonBoxes[a]);
                }
            }
            archonBoxes = {};
            maxArchons = 0;

            drawPointsBar();
            drawWinMarkers();
        }

        private function drawArchonBoxes():void {
            var top:Number = teamNameBox.height + teamNameBox.y;
            var i:uint = 0;
            for (var a:String in archonBoxes) {
                var archonBox:DrawHUDArchon = archonBoxes[a];
                archonBox.x = 5 + i * (archonBox.width + 5);
                archonBox.y = top;
                i++;
            }
        }

        private function drawUnitCounts():void {
            var top:Number = teamNameBox.height + teamNameBox.y + DrawHUDArchon.HEIGHT + 10;
            var i:uint = 0;
            for each (var unitBox:DrawHUDUnit in unitBoxes) {
                unitBox.x = 5 + i * (unitBox.width + 5);
                unitBox.y = top;
                i++;
            }
        }

        private function drawWinMarkers():void {
            var matches:Vector.<Match> = controller.getMatches();
            winMarkerCanvas.graphics.clear();
            var i:uint, wins:uint = 0;
            var r:Number = (winMarkerCanvas.height - 20) / 2;
            var numMatches:int =
                    (controller.currentRound == controller.match.getRounds()) ?
                            controller.currentMatch :
                            controller.currentMatch - 1;
            for (i = 0; i <= numMatches; i++) {
                if (matches[i].getWinner() == team) {
                    var x:Number = winMarkerCanvas.width - (r + 10) - (wins * (r * 2 + 5));
                    var y:Number = winMarkerCanvas.height / 2;
                    winMarkerCanvas.graphics.lineStyle();
                    winMarkerCanvas.graphics.beginFill(0xFFFFFF);
                    winMarkerCanvas.graphics.drawCircle(x, y, r);
                    winMarkerCanvas.graphics.endFill();
                    wins++;
                }
            }
        }

        private function drawPointsBar():void {
            var partCount:uint = controller.currentState.getPartCount(team);
            var armyValue:uint = controller.currentState.getArmyValue(team);
            pointsLabel.text = "" + (partCount + armyValue);

            var w:Number = Math.min(1, (partCount + armyValue) / 5000) * pointsCanvas.width;
            pointsCanvas.graphics.clear();
            pointsCanvas.graphics.lineStyle();
            pointsCanvas.graphics.beginFill(0xFFFFFF, 0.5);
            pointsCanvas.graphics.drawRect(0, pointsCanvas.height - 4, w, 4);
            pointsCanvas.graphics.endFill();
        }

        private function onResize(e:ResizeEvent):void {
            drawArchonBoxes();
            drawUnitCounts();
            drawPointsBar();
        }

    }

}