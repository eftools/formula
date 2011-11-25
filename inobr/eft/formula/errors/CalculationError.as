package inobr.eft.formula.errors 
{
	/**
	 * Any calculation error.
	 * 
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class CalculationError extends Error implements IElementError
	{
		private var _instance:Object;
		public function CalculationError(message:*, instance:*) 
		{
			_instance = instance;
			super(message, 0);
		}
		
		public function get instance():Object
		{
			return _instance;
		}
	}

}