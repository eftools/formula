package inobr.eft.formula.core 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.*;
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.core.managers.FocusManager;
	
	/**
	 * ...
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class BaseExpression extends Sprite implements IFormulaItem 
	{
		protected var _myParent:Object = null;
		protected var _selected:Boolean = false;
		private var _showWhileEmpty:Boolean;
		
		// Background color as uint. For example 0xFF0000.		
		private var _backgroundColor:uint;
		
		protected var _innerItems:Array /* of Sprites */ = [];
		
		public function BaseExpression(_parent:Object) 
		{
			_myParent = _parent;
			
			// listen to the MultipleElement added to stage
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(event:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addEventListener(Event.CHANGE, changed);
			
			_innerItems[0].setFocus("left");
			
			changed(null);
		}
		
		protected function changed(event:Event):void
		{
			// Nothing to do! Each element must have its own behaviour.
		}
		
		public function setSelection(direction:String = "all"):void
		{
			_selected = true;
			
			for each (var item:IFormulaItem in _innerItems) 
			{
				item.setSelection(direction);
			}
		}
		
		public function clearSelection():void
		{
			_selected = false;
			
			for each (var item:IFormulaItem in _innerItems) 
			{
				item.clearSelection();
			}
		}
		
		public function get innerItems():Array
		{
			return _innerItems;
		}
		
		public function removeYourself(deleteMe:Object = null, onlyContent:Boolean = false):void
		{
			// delete some object
			if (deleteMe != null)
			{
				//trace("before: " + _innerItems);
				for (var j:int = 0; j < _innerItems.length; j++) 
				{
					if (_innerItems[j] == deleteMe)
					{
						this.removeChild(deleteMe as DisplayObject);
						_innerItems.splice(j, 1);
						break;
					}
				}
			}
			// delete all this object
			else
			{
				removeEventListener(Event.CHANGE, changed);
				
				for (var i:int = 0; i < _innerItems.length; i++) 
				{
					_innerItems[i].removeYourself();
				}
				
				_myParent.removeYourself(this);
			}
			
			// say about changes in Expression in order to resize all items
			dispatchEvent(new Event(Event.CHANGE, true));
		}
		
		public function setFocus(position:String):void 
		{
			if(position == "left")
				_innerItems[_innerItems.length - 1].setFocus(position);
			else
				_innerItems[0].setFocus(position);
		}
		
		public function moveFocus(fromObject:Object, direction:String):void
		{
			var pos:int = _innerItems.indexOf(fromObject);
			if (pos == -1)
				return;
			
			if (direction == "left")
			{
				if (pos == 0)
				{
					if (_myParent is BaseExpression)
						_myParent.moveFocus(this, "left");
				}
				else
				{
					_innerItems[pos - 1].setFocus("left");
				}
			}
			
			if (direction == "right")
			{
				if (pos == _innerItems.length - 1)
				{
					if (_myParent is BaseExpression)
						_myParent.moveFocus(this, "right");
				}
				else
				{
					_innerItems[pos + 1].setFocus("right");
				}
			}
		}
		
		/**
		 * Trying to calculate this block and returns result or an error.
		 * @return
		 */
		public function getValue():Array 
		{
			throw new Error("getValue method must be overriden!");
			return null;
		}
		
		public function set showWhileEmpty(setValue:Boolean):void
		{
			_showWhileEmpty = setValue;
			if (_innerItems.length == 1 && _innerItems[0] is TextLeaf)
				{
					_innerItems[0].showWhileEmpty = true;
				}
		}
		
		public function get showWhileEmpty():Boolean
		{
			return _showWhileEmpty;
		}
		
		/**
		 * Sets up background color for the element.
		 * 
		 * @param	setValue	Color code as uint. For example 0xFF0000.
		 */
		public function set backgroundColor(setValue:uint):void
		{
			_backgroundColor = setValue;
			if (_innerItems.length == 1 && _innerItems[0] is TextLeaf)
				{
					_innerItems[0].backgroundColor = _backgroundColor;
				}
		}
		
		/**
		 * All adjacent elements should be positioned relative to the CENTRAL LINE
		 * Example: for Fraction Central line is the height of Numerator and
		 * for Sinus it is the half of its height.
		 */
		public function get centralLineY():uint
		{
			return this.height / 2;
		}
		
		public function setInnerElement(newElement:BaseExpression):void 
		{
			var focusHolder:TextLeaf = FocusManager.focusHolder;
			// split text in two substrings
			var sharedText:String = focusHolder.innerText.text;
			var leftText:String = "";
			var rightText:String = "";
			
			leftText = sharedText.substr(0, focusHolder.innerText.caretIndex);
			rightText = sharedText.substr(focusHolder.innerText.caretIndex, sharedText.length);
			
			// change the text to the left of new Element
			focusHolder.innerText.text = leftText;
			
			focusHolder.showWhileEmpty = false;
			
			// search for focuseHolder element in the _innerItems list
			// coordinates of the new element are depend on variable "i"
			var i:int = 0;
			for (i = 0; i < _innerItems.length; i++) 
			{
				if (_innerItems[i] == focusHolder)
					break;
			}
			// set coordinates to the new Element according to previous elements width and x-coordinate
			if (i > 0)
				newElement.x = _innerItems[i - 1].x + _innerItems[i - 1].width;
			else
				newElement.x = _innerItems[0].x + _innerItems[0].width;
				
			// write new Element to the _innerItems list
			_innerItems.splice(i + 1, 0, newElement);	
			this.addChild(DisplayObject(newElement));
			
			// add TextLeaf after the innerComlex and set its text
			var rightTextLeaf:TextLeaf = new TextLeaf(rightText);
			rightTextLeaf.x = _innerItems[i + 1].x + _innerItems[i + 1].width;
			rightTextLeaf.myParent = this;
			rightTextLeaf.showWhileEmpty = false;
			_innerItems.splice(i + 2, 0, rightTextLeaf);
			this.addChild(rightTextLeaf);
			
			// say about changes in Expression in order to resize all items
			dispatchEvent(new Event(Event.CHANGE, true));
		}
		
		/**
		 * Insert list of items in element.
		 * @param	list	of items to be inserted
		 */
		public function addListOfItems(list:Array):void
		{
			var mainItem:BaseExpression = getMainItem();
			if (mainItem == null)
				return;
				
			// delete all inner items from mainItem
			if (mainItem.innerItems[0])
			{
				mainItem.innerItems[0].removeYourself();
				mainItem.innerItems.length = 0;
			}
			// put new elements in mainItem
			for (var i:int = 0; i < list.length; i++) 
			{
				list[i].myParent = mainItem;
				mainItem.addChild(list[i]);
				mainItem.innerItems.push(list[i]);
			}
			// say that mainItem has been changed
			mainItem.dispatchEvent(new Event(Event.CHANGE, true));
		}
		
		/**
		 * Returns a link to main item of element (it may be Numerator in fraction or
		 * base in power or argument of sinus etc.).
		 * Main element resive focus right after creation.
		 * Main element resive selected elements after creation.
		 * @return	link to main item of element
		 */
		protected function getMainItem():BaseExpression
		{
			for each (var item:IFormulaItem in _innerItems) 
			{
				if (item is BaseExpression)
					return item as BaseExpression;
			}
			return null;
		}
		
		/**
		 * Adds element to innerItems and displayes it.
		 * 
		 * @param	element	Element to add as MultipleElement
		 */
		protected function addElement(element:MultipleElement):void
		{			
			_innerItems.push(element);
			addChild(element);
		}

		public function isUnbreakable():Boolean
		{
			return false;
		}
		
		public function set myParent(setValue:Object):void
		{
			_myParent = setValue;
		}
		
		public function get myParent():Object
		{
			return _myParent;
		}
		
		public function removeNextItem(item:TextLeaf):void
		{
			var pos:int = _innerItems.indexOf(item);
			if (pos != -1 && pos + 1 < _innerItems.length && _innerItems[pos + 1] is BaseExpression)
			{
				_innerItems[pos + 1].removeYourself();
				if (_innerItems[pos + 1] is TextLeaf) mergeTextLeafWithNextTextLeaf(item)
				else trace("Assert!!!! Wrong removeNextItem call!!!");
			}
		}
		
		public function mergeTextLeafWithNextTextLeaf(textLeaf:TextLeaf):void
		{
			var pos:int = _innerItems.indexOf(textLeaf);
			if (pos != -1 && pos + 1 < _innerItems.length && _innerItems[pos + 1] is TextLeaf)
			{
				textLeaf.innerText.appendText(_innerItems[pos + 1].innerText.text);
				_innerItems[pos + 1].removeYourself(null, true);
				textLeaf.update();
			}
			else trace("Assert!!!! Wrong MergeTextLeafWithNextTextLeaf call!!!");
		}
	}

}