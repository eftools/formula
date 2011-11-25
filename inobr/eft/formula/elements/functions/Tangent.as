package inobr.eft.formula.elements.functions 
{
	import flash.display.SimpleButton;
	import flash.events.*;
	import flash.utils.*;

	
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.core.managers.FocusManager;
	import inobr.eft.formula.events.*;
	import inobr.eft.formula.errors.CalculationError;
	import inobr.eft.common.lang.*;
	
	/**
	 * Tangent element.
	 * 
	 * @author Artyom Philonenko <greshnikk@gmail.com>
	 */
	public class Tangent extends BaseFunctionWithoutIndex
	{	
		/**
		 * Tangent element.
		 * 
		 * @param	_parent
		 */
		public function Tangent(_parent:Object):void
		{
			super(_parent);
			
			drawFunction("tg");
		}
		
		/**
		 * Returns button that will represent Cosinus on the toolbar
		 * You can use library item or draw this button programmatically
		 * Recommended size of this button is 30x30
		 */
		public static function getToolbarItem():SimpleButton
		{
			var toolbarItem:SimpleButton = new AddTangentButton();
			
			toolbarItem.addEventListener(MouseEvent.CLICK, toolbarItemClicked);
			
			return toolbarItem;
		}
		
		private static function toolbarItemClicked(event:MouseEvent):void
		{
			// parameter of the AddNewElementEvent must be the name of Class
			FocusManager.instance.dispatchEvent(new AddNewElementEvent(Tangent));
		}
		
		override protected function mathFunction(argument:Number):Number 
		{
			if (argument == 90)
			{
				throw new CalculationError(T('TangentOfNinetyError'), this);
			}
			var tangent:Number = Math.tan(argument * Math.PI / 180);
			return tangent;
		}
	}
}