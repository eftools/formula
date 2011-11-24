package inobr.eft.formula.events 
{
	import flash.events.Event;
	
	/**
	 * Event to discribe selection process.
	 * 
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class SelectionProcessEvent extends Event 
	{
		public static const SELECTION_PROCESS:String = "selectionProcess";
		public static const DELETE_SELECTED:String = "deleteSelected";
		
		public var selectionStatus:String = "end";
		public var eventSource:Object;
		
		public function SelectionProcessEvent(status:String, eventSource:Object, type:String = "selectionProcess", 
											  bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			super(type, bubbles, cancelable);
			
			this.selectionStatus = status;
			this.eventSource = eventSource;
		}
		
		public override function clone():Event
		{
			return new SelectionProcessEvent(selectionStatus, eventSource, type, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString(SELECTION_PROCESS, selectionStatus, "bubbles", "cancelable", "eventPhase");
		}
		
	}
}