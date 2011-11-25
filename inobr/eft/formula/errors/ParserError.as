package inobr.eft.formula.errors 
{
	/**
	 * Any parser error.
	 * 
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class ParserError extends Error implements IElementError
	{
		private var _instance:Object;
		public function ParserError(message:*, instance:Object) 
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