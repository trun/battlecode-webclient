package battlecode.client.viewer.render {
	
	import battlecode.client.viewer.MatchController;
	import battlecode.common.GameConstants;
	import battlecode.common.Team;
	import battlecode.events.MatchEvent;
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.events.FlexEvent;
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
			this.toolTip += "Game " + (controller.currentMatch+1) + " of " + controller.totalMatches + "\n";
			this.toolTip += "Map: " + controller.match.getMapName() + "\n";
		}
		
		private function drawDomBar():void {
			var aPoints:uint = controller.currentState.getPoints(Team.A);
			var bPoints:uint = controller.currentState.getPoints(Team.B);
			
			var centerWidth:Number = this.domBarCanvas.width / 2;
			var centerHeight:Number = this.domBarCanvas.height / 2;
			var barMaxWidth:Number = (this.domBarCanvas.width / 2) * .8;
			
			this.domBarCanvas.graphics.clear();
		}
		
	}
	
}