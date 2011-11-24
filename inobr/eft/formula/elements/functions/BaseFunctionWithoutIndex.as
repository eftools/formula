package inobr.eft.formula.elements.functions 
{
	import flash.events.*;
	import flash.utils.*;
	
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.events.*;
	import inobr.eft.common.lang.*;
	
	
	/**
	 * The BaseFunctionWithoutIndex class is used as parent for any function class
	 * that mustn't have index.
	 * 
	 * @author Artyom Philonenko <greshnikk@gmail.com>
	 */
	public class BaseFunctionWithoutIndex extends BaseFunction 
	{
		public function BaseFunctionWithoutIndex(_parent:Object)
		{
			super(_parent);
		}
		
		override protected function addIndex():void 
		{
			// nothing to do because index is not needed
		}
		
		override public function getValue():Array
		{
			var result:Array = [];
			var argumentValues:Array = _argument.getValue();
			var powValues:Array = _pow.getValue();
			if (powValues[0] == "NaN")
				powValues[0] = 1;
				
			if (argumentValues[0] == "NaN")
			{
				var errorMessage:String = T('NoArgument');
				throw new Error( { "instance":this, "errorMessage":errorMessage } );	
			}
			
			var valuesNum:int = Math.max(argumentValues.length, powValues.length);
			for (var i:int = 0; i < valuesNum; i++) 
			{
				var a:int;
				var p:int;
				argumentValues[i] ? a = i : a = 0;
				powValues[i] ? p = i : p = 0;
				var value:Number = Math.pow(mathFunction(argumentValues[a]), powValues[p]);
					
				result[i] = String(value);
			}	
			
			return result;
		}
		
		protected function mathFunction(argument:Number):Number
		{
			throw new Error("mathFunction method must be overriden!");
			return 0;
		}
	}
}