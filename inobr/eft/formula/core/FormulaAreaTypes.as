package inobr.eft.formula.core 
{
	/**
	 * Set of constants that determine functionality of formula workspace.
	 * 
	 * @author Gerasimenko Peter (gpstmp@gmail.com)
	 */
	public final class FormulaAreaTypes 
	{
		/**
		 * Specifies that in formula area will be only one formula with check tool.
		 * After checking user will see a window with right or wrong comment.
		 */
		public static const CHECK:String = "formulaCheck";
		
		/**
		 * Specifies that in formula area will be only one formula with calculate tool.
		 * After calculating user will see a window with right or wrong comment and the
		 * result of calculating.
		 */
		public static const SINGLE_CALCULATE:String = "formulaCalculate";
		
		/**
		 * Specifies that in formula area will several formulas with calculate and delete tools.
		 * There will be buttons that add new formulas.
		 * After calculating user will see a window with right or wrong comment and the
		 * result of calculating.
		 */
		public static const MULTIPLE_CALCULATE:String = "formulasCalculate";
		
	}

}