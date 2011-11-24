package inobr.eft.formula.elements.functions 
{
	import flash.display.SimpleButton;
	import flash.events.*;
	import flash.utils.*;
	
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.core.managers.FocusManager;
	import inobr.eft.formula.events.*;
	
	/**
	 * Cosinus element.
	 * 
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class Cosinus extends BaseFunctionWithoutIndex
	{	
		/**
		 * Cosinus element.
		 * 
		 * @param	_parent
		 */
		public function Cosinus(_parent:Object):void
		{
			super(_parent);
			
			drawFunction("cos");
		}
		
		/**
		 * Returns button that will represent Cosinus on the toolbar
		 * You can use library item or draw this button programmatically
		 * Recommended size of this button is 30x30
		 */
		public static function getToolbarItem():SimpleButton
		{
			var toolbarItem:SimpleButton = new AddCosinusButton();
			
			toolbarItem.addEventListener(MouseEvent.CLICK, toolbarItemClicked);
			
			return toolbarItem;
		}
		
		private static function toolbarItemClicked(event:MouseEvent):void
		{
			// parameter of the AddNewElementEvent must be the name of Class
			FocusManager.instance.dispatchEvent(new AddNewElementEvent(Cosinus));
		}
		
		override protected function mathFunction(argument:Number):Number 
		{
			var cosinus:Number = Math.cos(argument * Math.PI / 180);
			return cosinus;
		}	
	}
}