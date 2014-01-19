package battlecode.client.viewer.render {

    import battlecode.client.viewer.MatchController;
    import battlecode.common.Team;
    import battlecode.events.MatchEvent;

    import flash.display.GradientType;
    import flash.geom.Matrix;

    import mx.containers.Canvas;
    import mx.containers.HBox;
    import mx.controls.Label;
    import mx.events.ResizeEvent;

    public class DrawDominationBar extends HBox {
        private var controller:MatchController;
        private var domBarCanvas:Canvas;
        private var leftDomLabel:Label;
        private var rightDomLabel:Label;
        private var lastRound:uint = 0;

        public function DrawDominationBar(controller:MatchController) {
            super();

            this.controller = controller;
            this.controller.addEventListener(MatchEvent.ROUND_CHANGE, onRoundChange);
            this.controller.addEventListener(MatchEvent.MATCH_CHANGE, onMatchChange);

            this.height = 50;

            domBarCanvas = new Canvas();
            domBarCanvas.percentHeight = 100;
            domBarCanvas.percentWidth = 100;
            domBarCanvas.horizontalScrollPolicy = "off";
            domBarCanvas.verticalScrollPolicy = "off";
            domBarCanvas.addEventListener(ResizeEvent.RESIZE, onResize);

            leftDomLabel = new Label();
            leftDomLabel.setStyle("color", 0xFFFFFF);
            leftDomLabel.setStyle("fontSize", 14);
            leftDomLabel.setStyle("fontWeight", "bold");
            leftDomLabel.setStyle("textAlign", "center");
            leftDomLabel.setStyle("fontFamily", "Courier New");

            rightDomLabel = new Label();
            rightDomLabel.setStyle("color", 0xFFFFFF);
            rightDomLabel.setStyle("fontSize", 14);
            rightDomLabel.setStyle("fontWeight", "bold");
            rightDomLabel.setStyle("textAlign", "center");
            rightDomLabel.setStyle("fontFamily", "Courier New");

            addChild(domBarCanvas);
            domBarCanvas.addChild(leftDomLabel);
            domBarCanvas.addChild(rightDomLabel);
        }

        private function onResize(e:ResizeEvent):void {
            redrawAll();
        }

        private function onRoundChange(e:MatchEvent):void {
            drawDomBar();
        }

        private function onMatchChange(e:MatchEvent):void {
            updateTooltip();
            drawDomBar();
        }

        public function redrawAll():void {
            drawDomBar();
        }

        private function updateTooltip():void {
            this.toolTip = controller.match.getTeamA() + " vs. " + controller.match.getTeamB() + "\n";
            this.toolTip += "Game " + (controller.currentMatch + 1) + " of " + controller.totalMatches + "\n";
            this.toolTip += "Map: " + controller.match.getMapName() + "\n";
        }

        private function drawDomBar():void {
            var aPoints:uint = controller.currentState.getPoints(Team.A);
            var bPoints:uint = controller.currentState.getPoints(Team.B);

            var centerWidth:Number = this.domBarCanvas.width / 2;
            var centerHeight:Number = this.domBarCanvas.height / 2;
            var barMaxWidth:Number = (this.domBarCanvas.width / 2) * .8;

            this.domBarCanvas.graphics.clear();

            var minDomPts:int = 10000000;
            var sideRatio:Number = minDomPts / 10000000;

            leftDomLabel.text = "(+" + minDomPts.toString() + ")";
            leftDomLabel.y = centerHeight - (leftDomLabel.height / 2) - 10;
            leftDomLabel.x = centerWidth - barMaxWidth * sideRatio - leftDomLabel.width / 2;

            rightDomLabel.text = "(+" + minDomPts.toString() + ")";
            rightDomLabel.y = centerHeight - (rightDomLabel.height / 2) - 10;
            rightDomLabel.x = centerWidth + barMaxWidth * sideRatio - rightDomLabel.width / 2;

            // side spikes
            this.domBarCanvas.graphics.lineStyle(2, 0xFF6666);
            this.domBarCanvas.graphics.moveTo(centerWidth - barMaxWidth * sideRatio + 1, centerHeight + 10);
            this.domBarCanvas.graphics.lineTo(centerWidth - barMaxWidth * sideRatio + 1, centerHeight + 2);

            this.domBarCanvas.graphics.lineStyle(2, 0x9999FF);
            this.domBarCanvas.graphics.moveTo(centerWidth + barMaxWidth * sideRatio - 1, centerHeight + 10);
            this.domBarCanvas.graphics.lineTo(centerWidth + barMaxWidth * sideRatio - 1, centerHeight + 2);

            // domination
            var topFill:uint = (aPoints > bPoints) ? 0xFFCCCC : 0xCCCCFF;
            var bottomFill:uint = (aPoints > bPoints) ? 0xFF0000 : 0x0000FF;
            var domBarWidth:Number = (aPoints - bPoints) / 10000000 * barMaxWidth;
            if (domBarWidth < -barMaxWidth) domBarWidth = -barMaxWidth;
            if (domBarWidth > barMaxWidth) domBarWidth = barMaxWidth;

            var fillMatrix:Matrix = new Matrix();
            fillMatrix.createGradientBox(barMaxWidth, 12, Math.PI/2, centerWidth, centerHeight - 0);

            this.domBarCanvas.graphics.lineStyle(1, 0xFFFFFF);
            this.domBarCanvas.graphics.beginGradientFill(GradientType.LINEAR, [topFill, bottomFill], [1, 1], [0, 255], fillMatrix, "pad");
            this.domBarCanvas.graphics.drawRect(centerWidth, centerHeight - 0, -domBarWidth, 12);
            this.domBarCanvas.graphics.endFill();

            // center spike
            this.domBarCanvas.graphics.lineStyle(4, 0xCCCCCC);
            this.domBarCanvas.graphics.moveTo(centerWidth, centerHeight + 16);
            this.domBarCanvas.graphics.lineTo(centerWidth, centerHeight - 4);
        }

    }

}