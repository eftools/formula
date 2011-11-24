package inobr.eft.formula.core 
{
	import flash.text.TextFormat;
	
	/**
	 * Default options that are used in framework.
	 * 
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class Defaults 
	{
		/**
		 * Default text format.
		 */
		public static const TEXT_SETTINGS:TextFormat = new TextFormat("Tahoma", 20, 0x990033, true);
		/**
		 * Default scale of sub or sup indexes.
		 */
		public static const SCALE:Number = 0.6;
		public static const MARGIN:Number = 10;
	}
}