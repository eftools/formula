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
	 * Logarithm element.
	 * 
	 * @author Artyom Philonenko <greshnikk@gmail.com>
	 */
	public class Logarithm extends BaseFunction
	{	
		/**
		 * Logarithm element. Degree and base are editable.
		 * 
		 * @param	_parent
		 */
		public function Logarithm(_parent:Object):void
		{
			super(_parent);
			
			drawFunction("log");
		}
		
		/**
		 * Returns button that will represent Cosinus on the toolbar
		 * You can use library item or draw this button programmatically
		 * Recommended size of this button is 30x30
		 */
		public static function getToolbarItem():SimpleButton
		{
			var toolbarItem:SimpleButton = new AddLogarithmButton();
			
			toolbarItem.addEventListener(MouseEvent.CLICK, toolbarItemClicked);
			
			return toolbarItem;
		}
		
		private static function toolbarItemClicked(event:MouseEvent):void
		{
			// parameter of the AddNewElementEvent must be the name of Class
			FocusManager.instance.dispatchEvent(new AddNewElementEvent(Logarithm));
		}
		
		override public function getValue():Array 
		{
			var argumentValues:Array = _argument.getValue();
			var powValues:Array = _pow.getValue();
			var indexValues:Array = _index.getValue();
			var result:Array = [];
			if (powValues[0] == "NaN")
				powValues[0] = 1;
				
			var valuesNum:int = Math.max(argumentValues.length, powValues.length, indexValues.length);
			for (var i:int = 0; i < valuesNum; i++) 
			{
				var a:int;
				var p:int;
				var b:int;
				argumentValues[i] ? a = i : a = 0;
				powValues[i] ? p = i : p = 0;
				indexValues[i] ? b = i : b = 0;
				// error checking
				if (argumentValues[0] == "NaN" || indexValues[0] == "NaN")
				{
					var errorMessage:String = T('NoArgument');
					throw new Error( { "instance":this, "errorMessage":errorMessage } );	
				}
				if (argumentValues[a] <= 0)
				{
					errorMessage = T('NegativeNumberInLog');
					throw new Error( { "instance":this, "errorMessage":errorMessage } );	
				}
				if (indexValues[a] <= 0)
				{
					errorMessage = T('NegativeNumberInLogBase');
					throw new Error( { "instance":this, "errorMessage":errorMessage } );	
				}
				if (indexValues[a] == 1)
				{
					errorMessage = T('OneInLogBase');
					throw new Error( { "instance":this, "errorMessage":errorMessage } );	
				}
				
				var value:Number = Math.pow(Math.log(argumentValues[a]) / Math.log(indexValues[b]), powValues[p]);
					
				result[i] = String(value);
			}	
			
			return result;
		}		
	}
}