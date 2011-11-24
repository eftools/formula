package inobr.eft.formula.core.managers 
{
	import flash.events.*;
	import flash.text.TextField;
	import inobr.eft.formula.events.CalculatorEvents;
	
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.events.SelectionProcessEvent;
	/**
	 * Manages the process of selection.
	 * 
	 * ...
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class SelectionManager extends EventDispatcher
	{
		// create and remember the only one exemplar of SelectionManager class
		private static var _instance:SelectionManager = new SelectionManager();
		// global indicator of selection process
		private static var _selectionStatus:String;
		// list of selected items
		private static var _selectedItems:Array = [];
		
		private var _firstObject:Object = null;
		private var _lastObject:Object = null;
		private var _selectionLevel:Object = null;
		
		public function SelectionManager():void
		{
			if (_instance != null)
				throw new Error("An instance of SelectionManager already exists! You can not create another instance of SelectionManager class.");
			
			// add listeners to the SelectionProcessEvent
			addEventListener(SelectionProcessEvent.SELECTION_PROCESS, selectionProcessHandler);
			addEventListener(SelectionProcessEvent.DELETE_SELECTED, deleteSelectedHandler);
			addEventListener(CalculatorEvents.DESELECT, deselectHandler);
		}
		
		private function selectionProcessHandler(event:SelectionProcessEvent):void
		{
			if (event.selectionStatus == "is")
			{	
				clearSelection();
				if (_firstObject != event.eventSource)
				{
					_lastObject = event.eventSource;
					setSelection();
				}
			}
			// clear old selection and begin new
			if (event.selectionStatus == "begin")
			{
				clearSelection(true);
				_firstObject = event.eventSource;
				_selectionStatus = "is";
			}
			if (event.selectionStatus == "end")
			{
				_selectionStatus = "end";
			}
		}
		
		private function setSelection():void
		{
			// make temporary vars in case of changing start and finish points (of selection) 
			var firstObjectTmp:Object = _firstObject;
			var lastObjectTmp:Object = _lastObject;
			
			_selectionLevel = firstObjectTmp.myParent;
			
			// check level of _firstObject and _lastObject
			if (firstObjectTmp.myParent != lastObjectTmp.myParent)
			{
				var sameParent:Object = getSameLevelParent(firstObjectTmp, lastObjectTmp);
				
				if (sameParent != null)
					lastObjectTmp = sameParent;
				else
				{
					sameParent = getSameLevelParent(lastObjectTmp, firstObjectTmp);
					if (sameParent != null)
					{
						firstObjectTmp = lastObjectTmp;
						lastObjectTmp = sameParent;
						_selectionLevel = firstObjectTmp.myParent;
					}
				}
				
			}
			
			var firstObjectIndex:int = 0;
			var lastObjectIndex:int = 0;
			// find start and finish points of selection
			
			firstObjectIndex = _selectionLevel.innerItems.indexOf(firstObjectTmp);
			lastObjectIndex = _selectionLevel.innerItems.indexOf(lastObjectTmp);
			
			firstObjectIndex = (firstObjectIndex == -1) ? 0 : firstObjectIndex;
			lastObjectIndex = (lastObjectIndex == -1) ? 0 : lastObjectIndex;
			
			_selectedItems.length = 0;
			
			// if finish point is before start point we change _selectedItems
			if (firstObjectIndex < lastObjectIndex)
			{
				for (var i:int = firstObjectIndex; i < lastObjectIndex + 1; i++) 
				{
					_selectedItems.push(_selectionLevel.innerItems[i]);
				}
			}
			else
			{
				for (i = lastObjectIndex; i < firstObjectIndex + 1; i++) 
				{
					_selectedItems.push(_selectionLevel.innerItems[i]);
				}
			}
			
			// determine derection of selection
			var direction:String = "left";
			if (lastObjectIndex - firstObjectIndex > 0)
				direction = "right";
			
			if (_lastObject != lastObjectTmp)
				(direction == "left") ? direction = "right" : direction = "left";
				
			// setSelection for all items except the _firstObject and the _lastObject
			for (i = 0; i < _selectedItems.length; i++) 
			{
				if (_firstObject != _selectedItems[i] && _lastObject != _selectedItems[i])
					_selectedItems[i].setSelection();
				
				if (_lastObject == _selectedItems[i])
					_selectedItems[i].setSelection(direction);
			}
		}
		
		/**
		 * Looks for the first shared object (myParent) in the display tree.
		 * And returns this Object or null if there is no such one.
		 * 
		 * @param	first
		 * @param	last
		 * @return	first shared object
		 */
		private function getSameLevelParent(first:Object, last:Object):Object
		{
			var tempParent:Object = last;
			while (first.myParent != tempParent.myParent) 
			{
				if (tempParent.myParent is BaseExpression)
					tempParent = tempParent.myParent;
				else
				{
					tempParent = null;
					break;
				}
			}
			
			return tempParent;
		}
		
		private function clearSelection(all:Boolean = false):void
		{
			for (var i:int = 0; i < _selectedItems.length; i++) 
			{
				if (all ? true : _firstObject != _selectedItems[i]) _selectedItems[i].clearSelection();
			}
		}
		
		private function deleteSelectedHandler(event:Event):void
		{
			// nothing to do if there is no selected objects
			if (_selectedItems[0] == null)
				return;
				
			// delete all selected
			// if _selectedItems == _innerItems of the parent, we mustn't
			// delete a textLeaf 
				
			// selectionLevel may be NULL if selection was made not by mouse dragging	
			if (_selectionLevel == null)
				_selectionLevel = _selectedItems[0].myParent;
				
			var inners:Array =  _selectedItems[0].myParent.innerItems;
			
			// in any case formula must end with the TextLeaf so we don't delete it
			if (_selectedItems[0] is TextLeaf)
			{
				_selectedItems[0].innerText.replaceSelectedText("");
				if (_selectedItems.toString() == inners.toString())
				{
					_selectedItems[0].showWhileEmpty = true;
				}
			}
			else
			{
				_selectedItems[0].removeYourself();
			}
			// all the selected objects after TextLeaf must be deleted completely
			for (var i:int = 1; i < _selectedItems.length; i++) 
			{
				_selectedItems[i].removeYourself();
			}
			
			// if first and last objects are TextLeaf we concatinate them
			// this case may happen when in first and last objects user selected only parts of text
			for (i = 0; i < _selectionLevel.innerItems.length - 1; i++) 
			{
				if (_selectionLevel.innerItems[i] is TextLeaf && _selectionLevel.innerItems[i + 1] is TextLeaf)
				{
					_selectionLevel.innerItems[i].innerText.appendText(_selectionLevel.innerItems[i + 1].innerText.text);
					_selectionLevel.innerItems[i].update();
					_selectionLevel.innerItems[i + 1].setSelection("all");
					_selectionLevel.innerItems[i + 1].removeYourself(null, true);
					break;
				}
			}
			
			// set focuse to the last object
			_selectionLevel.innerItems[_selectionLevel.innerItems.length - 1].setFocus("left");
			
			_selectedItems.length = 0;
		}
		
		private function deselectHandler(event:Event):void
		{
			// we must deselect all items (TextLeafs too)
			var tempParent:Object = FocusManager.focusHolder.myParent;
				
			while (tempParent.myParent is BaseExpression) 
			{
				tempParent = tempParent.myParent;
			}
			tempParent.clearSelection();
			
			_selectedItems.length = 0;
		}
		
		/**
		 * Make specified items selected. Used when selection is made not by
		 * mouse dragging (by single click for example).
		 * @param	items
		 */
		public function selectSpecifiedItems(items:Array):void
		{
			if (items)
			{
				_selectedItems = items;
			}
			else
				 _selectedItems.length = 0;
		}
		
		/**
		 * Instance of created exemplar of SelectionManager class in oder to
		 * add/remove any Global listener.
		 */
		public static function get instance():SelectionManager
		{
			return _instance;    
		}
		
		/**
		 * Indicates whether there is more than one selected items.
		 */
		public static function get isElementsSelected():Boolean
		{
			return _selectedItems.length > 0;
		}
		
		/**
		 * Get the status of selection process ("begin", "is" or "end").
		 */
		public static function get selectionStatus():String
		{
			return  _selectionStatus;
		}
		
		/**
		 * The link to the list of selected items.
		 */
		public static function get selectedItems():Array
		{
			return _selectedItems;
		}
		
	}

}