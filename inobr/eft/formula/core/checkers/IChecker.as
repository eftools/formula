package inobr.eft.formula.core.checkers 
{
	import inobr.eft.formula.core.MultipleElement;
	/**
	 * If developer wants to make his own way of checking
	 * he must implement this interface. 
	 * 
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public interface IChecker 
	{
		/**
		 * Resives link to the formula (always MultipleElement) and check it.
		 * This method must do three things:
		 * 1) return TRUE if checking was success
		 * 2) return FALSE if checking faild
		 * 
		 * @param	formula		MultipleElement
		 * @return	TRUE if formula is correct and FALSE othrwise
		 */
		function check(formula:MultipleElement):Boolean;
	}
	
}