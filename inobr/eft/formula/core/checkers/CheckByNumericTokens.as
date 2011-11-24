package inobr.eft.formula.core.checkers 
{
	import inobr.eft.formula.core.*;
	
	/**
	 * ...
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class CheckByNumericTokens implements IChecker 
	{
		private var _tokensToFind:Array = [];
		
		/**
		 * Checks if specified tokens are present in the formula.
		 * The order of tokens doesn't matter.
		 * 
		 * @param	...rest	any number of tokens (Numbers)
		 */
		public function CheckByNumericTokens(...rest)
		{
			for each (var item:* in rest) 
			{
				if (!(item is Number))
					throw Error("Token must be Numbers!");
			}
			
			_tokensToFind = rest;
		}
		
		private function getInnerTextLeafs(element:BaseExpression):Array
		{
			var listOfTokens:Array = [];
			for each (var item:* in element.innerItems) 
			{
				if (item is TextLeaf)
				{
					listOfTokens = listOfTokens.concat(item.getTokens());
					continue;
				}
				
				if (item is BaseExpression)
					listOfTokens = listOfTokens.concat(getInnerTextLeafs(item));
			}
			
			return listOfTokens;
		}
		
		/* INTERFACE IChecker */
		
		/**
		 * Resives link to the formula (always MultipleElement) and check it 
		 * tring to find specified tokens. Tokens are set when
		 * "new CheckByNumericTokens(tokens)" is used.
		 * 
		 * @param	formula	
		 * @return	TRUE if formula is correct and FALSE othrwise
		 */
		public function check(formula:MultipleElement):Boolean 
		{
			var listOfTokens:Array = getInnerTextLeafs(formula as BaseExpression);
			
			for each (var item:Number in _tokensToFind) 
			{
				if (!(listOfTokens.indexOf(item.toString()) + 1))
					return false;
			}
				
			return true;
		}
		
	}

}