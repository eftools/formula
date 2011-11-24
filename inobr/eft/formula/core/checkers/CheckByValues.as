package inobr.eft.formula.core.checkers 
{	
	import inobr.eft.formula.core.*;
	/**
	 * Implements IChecker. Test formula on a set of values (Array).
	 * If you use this checker you MUST set values to all variables!
	 * 
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class CheckByValues implements IChecker 
	{
		private var _verificationValues:Array = null;
		
		/**
		 * Implements IChecker. Test formula on a set of values (Array).
		 * If you use this checker you MUST set values to all variables!
		 * 
		 * @param	verificationValues	is the array of verification values for formula check.
		 * Please, pay attention to the precision of values! 1.1 and 1.11 
		 * are not equal!
		 */
		public function CheckByValues(verificationValues:Array) 
		{
			_verificationValues = verificationValues;
		}
			
		/* INTERFACE IChecker */
		/**
		 * Resives link to the formula (always MultipleElement) and check it.
		 * This method does returns two things:
		 * 1) TRUE if checking was success
		 * 2) FALSE if checking faild
		 * 
		 * @param	formula
		 * @return	TRUE if formula is correct and FALSE othrwise
		 */
		public function check(formula:MultipleElement):Boolean 
		{
			var resultNumber:Array = formula.Calculate();
				
			if (!resultNumber)
				return false;
				
			// compare with verification values
			for (var i:int = 0; i < resultNumber.length; i++) 
			{
				if (resultNumber[i] != _verificationValues[i])
					return false;
			}
			
			return true;
		}
		
	}

}