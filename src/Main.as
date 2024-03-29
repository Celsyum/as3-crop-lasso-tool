package 
{
	import com.cls.LassoCrop;
	import com.cls.LassoProps;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Celsyum 2012 Digital Zombies
	 */
	public class Main extends Sprite 
	{
		[Embed(source = "assets/test.png")]
		private var img:Class;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			var img:Bitmap = new img();
			img.y = 15;
			img.x = 25;
			img.scaleX = 0.7;
			img.scaleY = 1.3;
			addChild(img);
			
			var properties:LassoProps = new LassoProps();
			properties.lineThickness(2).lineColor(0xFFFFFF);
			var laso:LassoCrop = new LassoCrop(img, properties);
			
			
			/**
			 * also you can do this way
			 * 
			 * 	var laso:LassoCrop = new LassoCrop();
			 *	laso.properties = properties;
			 *	laso.target = img;
			 */
			
			 laso.addEventListener(LassoCrop.CROPPED, onCropped);
			
		}
		
		private function onCropped(e:Event):void 
		{
			var lass:LassoCrop = e.currentTarget as LassoCrop;
			// lass.hideSource(true); // if you want to see only masked
			
			var bit:Bitmap = lass.getResult(true);  //geting cropped part
			addChild(bit);
			bit.x = 200;
		}
		
	}
	
}