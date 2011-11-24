package inobr.eft.formula.elements.functions 
{
	import flash.display.SimpleButton;
	import flash.events.*;
	import flash.utils.*;
	
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.core.managers.FocusManager;
	import inobr.eft.formula.events.*;
	
	/**
	 * Common (decimal) logarithm.
	 * 
	 * @author Artyom Philonenko <greshnikk@gmail.com>
	 */
	public class CommonLogarithm extends BaseFunctionWithoutIndex
	{
		/**
		 * Common (decimal) logarithm.
		 * 
		 * @param	_parent
		 */
		public function CommonLogarithm(_parent:Object):void
		{
			super(_parent);
			
			drawFunction("lg");
		}
		
		/**
		 * Returns button that will represent Cosinus on the toolbar
		 * You can use library item or draw this button programmatically
		 * Recommended size of this button is 30x30
		 */
		public static function getToolbarItem():SimpleButton
		{
			var toolbarItem:SimpleButton = new AddCommonLogarithmButton();
			
			toolbarItem.addEventListener(MouseEvent.CLICK, toolbarItemClicked);
			
			return toolbarItem;
		}
		
		private static function toolbarItemClicked(event:MouseEvent):void
		{
			// parameter of the AddNewElementEvent must be the name of Class
			FocusManager.instance.dispatchEvent(new AddNewElementEvent(CommonLogarithm));
		}
		
		override protected function mathFunction(argument:Number):Number 
		{
			var commonLogarithm:Number = Math.log(argument) / Math.log(10);
			return commonLogarithm;
		}		
	}
}