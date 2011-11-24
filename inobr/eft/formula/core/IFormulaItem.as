package inobr.eft.formula.core 
{
	
	/**
	 * Interface of item that can be used as inner item in any 
	 * BaseExpression. Describes the behavior of selection
	 * and transfer of focus.
	 * 
	 * @author Peter Gerasimenko (gpstmp@gmail.com)
	 */
	public interface IFormulaItem 
	{
		function setSelection(direction:String = "all"):void;
		
		function clearSelection():void;
		
		function setFocus(position:String):void;
		
		
		
		function removeYourself(deleteMe:Object = null, forseDelete:Boolean = false):void;
		
		function get myParent():Object;
		
		function set myParent(setValue:Object):void;
		
		
		
		function set showWhileEmpty(setValue:Boolean):void;
		
		function get showWhileEmpty():Boolean;
		
		function set backgroundColor(setValue:uint):void;
		
		
		function isUnbreakable():Boolean;
	}
	
}