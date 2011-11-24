package inobr.eft.formula.core.managers
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import flash.net.DynamicPropertyOutput;
	import flash.utils.getDefinitionByName;
	
	import inobr.eft.formula.core.BaseExpression;
	import inobr.eft.formula.elements.functions.BaseFunctionWithoutIndex;
	import inobr.eft.formula.core.TextLeaf;
	import inobr.eft.formula.events.*;
	
	/**
	 * This is a singleton. It is Controller of Tool Panel, there are two ways of use: 
	 * 1) in DispatchingClass write
	 * FocusManager.instance.dispatchEvent(new Event("someevent"));
	 * 2) in ListeningClass  write
	 * FocusManager.instance.addEventListener(Event.SOMEEVENT, onSomeEventHendler);
	 * 
	 * In any case this Event will be listend.
	 * The only method of this Class is  instance that returns a reference to the
	 * single object of this Class.
	 * 
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class FocusManager extends EventDispatcher
	{
		// create and remember the only one exemplar of FocusManager class
		private static var _instance:FocusManager = new FocusManager();
		// this is a link to the Object that will recive new element
		private static var _focusHolder:TextLeaf;
		
		public function FocusManager():void
		{ 
			if (_instance != null)
				throw new Error("An instance of FocusManager() already exists! You can not create another instance of FocusManager class.");
			
			// add Listener to the ADD_ELEMENT Event 
			this.addEventListener(AddNewElementEvent.ADD_ELEMENT, addElementHandler);
		}
		
		private function addElementHandler(event:AddNewElementEvent):void
		{
			// create newElement with specified parameters
			if(event.parameterToConstructor)
				var newElement:Object = new event.classForAdding(_focusHolder.myParent, event.parameterToConstructor);
			else
				newElement = new event.classForAdding(_focusHolder.myParent);
				
			// check if there are any selected items
			var selectedItems:Array = SelectionManager.selectedItems;
			if (selectedItems.length != 0)
			{
				// insert newcome element into innerItems and add it to display list
				var itemParent:Object = selectedItems[0].myParent;
				var itemIndex:int = (itemParent as BaseExpression).innerItems.indexOf(selectedItems[0]);
				(itemParent as BaseExpression).innerItems.splice(itemIndex + 1, 0, newElement);
				(itemParent as BaseExpression).addChild(newElement as DisplayObject);
					
				// form and insert list of items
				var list:Array = formListToInsert(selectedItems);
				(newElement as BaseExpression).addListOfItems(list);
				// clear selection after removing
				SelectionManager.instance.dispatchEvent(new Event(CalculatorEvents.DESELECT));
				return;
			}
				
			// check if there are any text selected in focusHolder (SelctionManager doesn't 
			// work with single TextField selection!)
			if (_focusHolder.innerText.selectedText != "")
			{
				list = formListToInsert([_focusHolder]);
				(newElement as BaseExpression).addListOfItems(list);
			}
			
            _focusHolder.myParent.setInnerElement(newElement);
			// clear selection after removing/adding
			SelectionManager.instance.dispatchEvent(new Event(CalculatorEvents.DESELECT));
		}
		
		/**
		 * Forming a list of items to insert into newcome element.
		 * @param	selectedItems	list of selected items from SelectionManager
		 * @return
		 */
		private function formListToInsert(selectedItems:Array):Array
		{
			var list:Array = [];
			
			// remove selected items from display list and special work with TextLeaf:
			// it is easier to recreate TextLeaf than to move.
			for (var i:int = 0; i < selectedItems.length; i++) 
			{
				if (selectedItems[i] is TextLeaf)
				{
					var selectedText:String = (selectedItems[i] as TextLeaf).innerText.selectedText;
					if (selectedText == "") continue;
					var newTextLeaf:TextLeaf = new TextLeaf(selectedText);
					(selectedItems[i] as TextLeaf).innerText.replaceSelectedText("");
					list.push(newTextLeaf);
				}
				else
				{
					var itemParent:Object = selectedItems[i].myParent;
					var itemIndex:int = (itemParent as BaseExpression).innerItems.indexOf(selectedItems[i]);
					(itemParent as BaseExpression).innerItems.splice(itemIndex, 1);
					itemParent.removeChild(selectedItems[i]);
					list.push(selectedItems[i]);
				}
			}
			
			return list;
		}
		
		/**
		 * Instance of created exemplar of FocusManager class in oder to
		 * add/remove any Global listener.
		 */
		public static function get instance():FocusManager
		{
			return _instance;    
		}
		
		/**
		 * Sets the TextLeaf that now has focus.
		 */
		public static function set focusHolder(setValue:TextLeaf):void
		{
			_focusHolder = setValue;
		}
		
		/**
		 * Link to the TextLeaf that now has focus.
		 */
		public static function get focusHolder():TextLeaf
		{
			return _focusHolder;
		}
		
	}
	
}