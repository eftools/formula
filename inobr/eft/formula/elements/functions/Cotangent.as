package inobr.eft.formula.elements.functions 
{
	import flash.display.SimpleButton;
	import flash.events.*;
	import flash.utils.*;
	
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.core.managers.FocusManager;
	import inobr.eft.formula.events.*;
	import inobr.eft.common.lang.*;
	
	/**
	 * Cotangent element.
	 * 
	 * @author Artyom Philonenko <greshnikk@gmail.com>
	 */
	public class Cotangent extends BaseFunctionWithoutIndex
	{
		/**
		 * Cotangent element.
		 * 
		 * @param	_parent
		 */
		public function Cotangent(_parent:Object):void
		{
			super(_parent);
			
			drawFunction("ctg");
		}
		
		/**
		 * Returns button that will represent Cosinus on the toolbar
		 * You can use library item or draw this button programmatically
		 * Recommended size of this button is 30x30
		 */
		public static function getToolbarItem():SimpleButton
		{
			var toolbarItem:SimpleButton = new AddCotangentButton();
			
			toolbarItem.addEventListener(MouseEvent.CLICK, toolbarItemClicked);
			
			return toolbarItem;
		}
		
		private static function toolbarItemClicked(event:MouseEvent):void
		{
			// parameter of the AddNewElementEvent must be the name of Class
			FocusManager.instance.dispatchEvent(new AddNewElementEvent(Cotangent));
		}
		
		override protected function mathFunction(argument:Number):Number 
		{
			if (argument == 0)
			{
				var errorMessage:String = T('CotangentOfZeroError');
				throw new Error( { "instance":this, "errorMessage":errorMessage } );
			}
			var cotangent:Number = 1 / Math.tan(argument * Math.PI / 180);
			return cotangent;
		}
	}
}