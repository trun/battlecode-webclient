package battlecode.client.viewer.render {
	import mx.controls.Image;
	import mx.core.UIComponent;
	
	public class ExplosionAnimation extends UIComponent implements DrawObject {
		
		private var image:Image;
		private var round:int = 0;
		private var exploding:Boolean = false;
		
		public function ExplosionAnimation() {
			this.image = new Image();
			this.addChild(image);
		}
		
		public function explode():void {
			exploding = true;
		}
		
		public function draw(force:Boolean = false):void {
			if (!RenderConfiguration.showExplosions()) {
				this.image.source = null;
				return;
			}
			
			var imageSource:Class = getExplosionImage();
			this.image.source = new imageSource();
			this.image.width = RenderConfiguration.getGridSize();
			this.image.height = RenderConfiguration.getGridSize();
			this.image.x = -RenderConfiguration.getGridSize()/2;
			this.image.y = -RenderConfiguration.getGridSize()/2;
		}
		
		public function clone():DrawObject{
			var anim:ExplosionAnimation = new ExplosionAnimation();
			anim.round = round;
			anim.exploding = exploding;
			return anim;
		}
		
		public function getRound():uint {
			return round;
		}
		
		public function isExploding():Boolean {
			return exploding;
		}
		
		public function isAlive():Boolean{
			return round < 8 && exploding;
		}
		
		public function updateRound():void{
			if (exploding) round++;
		}
		
		private function getExplosionImage():Class {
			switch (round) {
				case 0: return ImageAssets.EXPLODE_1;
				case 1: return ImageAssets.EXPLODE_2;
				case 2: return ImageAssets.EXPLODE_3;
				case 3: return ImageAssets.EXPLODE_4;
				case 4: return ImageAssets.EXPLODE_5;
				case 5: return ImageAssets.EXPLODE_6;
				case 6: return ImageAssets.EXPLODE_7;
				case 7: return ImageAssets.EXPLODE_8;
				default: return ImageAssets.EXPLODE_8;
			}
		}
		
	}
	
}