package inobr.eft.formula.events
{
	import flash.events.*;
	
	/**
	 * The basic Event for all Tool Pannel.
	 * If any Button must create a new element it must dispatch 
	 * this Event with the name of Class given.
	 *
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class AddNewElementEvent extends Event 
	{
		public static const ADD_ELEMENT:String = "addelement";
		// the name of the Class that must be created after the Button pressed
		public var classForAdding:Class;
		public var parameterToConstructor:*;
		
		public function AddNewElementEvent(classForAdding:Class, parameterToConstructor:* = NaN, type:String = "addelement", bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.classForAdding = classForAdding;
			this.parameterToConstructor = parameterToConstructor;
		}
		
		public override function clone():Event
		{
			return new AddNewElementEvent(classForAdding, parameterToConstructor, type, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString(ADD_ELEMENT, classForAdding, "bubbles", "cancelable", "eventPhase");
		}
	}
	
}