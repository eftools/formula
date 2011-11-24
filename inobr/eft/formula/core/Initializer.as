package inobr.eft.formula.core 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class Initializer extends Sprite 
	{
		
		public function Initializer() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			deleteListener();
			initialize();
		}
		
		private function deleteListener():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function initialize():void
		{
			// to override!
		}
	}

}