package inobr.eft.formula.core 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.core.managers.*;
	import inobr.eft.formula.events.*;
	import inobr.eft.formula.parser.Parser;
	import inobr.eft.common.lang.*;
	import inobr.eft.common.keyboard.*;
	
	
	
	/**
	 * ...
	 * @author Peter Gerasimenko (gpstmp@gmail.com)
	 */
	public class TextLeaf extends Sprite implements IFormulaItem
	{
		private static const EMPTYWIDTH:uint = 4;
		private static const RIGHTMARGIN:uint = 4;
		
		private var _myParent:Object;
		
		private var _innerText:TextField;
		private var _mask:Shape;
		
		private var _showWhileEmpty:Boolean = false;
		
		/**
		 * Background color as uint. For example 0xFF0000.
		 */
		private var _backgroundColor:uint = 0x6699FF;
		private var previousCaretIndex:uint = 0;
		
		private var _selected:Boolean = false;
		private var _startPoint:Point = new Point();
		private var _isCursorAtTheStartOnKeyDown:Boolean;
		private var _isCursorAtTheEndOnKeyDown:Boolean;
		
		/**
		 * Element for holding focus and typing text.
		 * The lowest level in hierarchy of items.
		 * 
		 * @param	withText	text to insert into element
		 */
		public function TextLeaf(withText:String = ""):void
		{
			drawTextLeaf(withText);
			// listen to the TextLeaf added to Stage
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// the height of empty TextField is far from been true before 
			// adding to stage so we mask it here and say that it has been changed
			// in order to fit size and coordinates of other elements
			_innerText.dispatchEvent(new Event(Event.CHANGE, true));
			maskTextField();
			
			_innerText.addEventListener(Event.CHANGE, textChangeHandler);
			_innerText.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			// prevent of default deleting
			_innerText.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			
			this.addEventListener(MouseEvent.CLICK, mouseClickHandler);
			
			// listeners for selection
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		private function drawTextLeaf(withText:String):void
		{
			var formatSettings:TextFormat = new TextFormat();
			formatSettings.font = "Tahoma";
			formatSettings.color = 0x990033;
			formatSettings.size = 20;
			formatSettings.bold = true;
			formatSettings.blockIndent = 0;
			formatSettings.indent = 0;
							
			var innerTextField:TextField = new TextField();
			innerTextField.type = "input";
			innerTextField.alwaysShowSelection = true;
			
			// allow to add only these symbols
			innerTextField.restrict = "0-9 * \\- + .";
			
			innerTextField.background = false;
				
			innerTextField.backgroundColor = _backgroundColor;
			
			innerTextField.text = withText;
			
			innerTextField.autoSize = TextFieldAutoSize.LEFT;
			
			innerTextField.setTextFormat(formatSettings);
			innerTextField.defaultTextFormat = formatSettings;
			innerTextField.selectable = true;
			
			// add new text field
			this.addChild(innerTextField);
			_innerText = innerTextField;
		}
		
		private function maskTextField():void
		{
			try 
			{
				removeChild(_mask);
			}
			catch (error:Error) { }
			
			_mask = new Shape();
			_mask.graphics.beginFill(0x000000);
			_mask.graphics.drawRect(0, 0, width, height);
			_mask.graphics.endFill();
			addChild(_mask);
			this.mask = _mask;
		}
		
		private function keyDownHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == KeyCodes.DEL) 
			{
				_isCursorAtTheEndOnKeyDown = _innerText.caretIndex == _innerText.length;
			}

			if (event.keyCode == KeyCodes.BACKSPACE)
			{
				_isCursorAtTheStartOnKeyDown = _innerText.caretIndex == 0;
			}
		}
		
		private function textChangeHandler(event:Event):void
		{	
			/* replace "*" with "·" and "-" to "–" for good looking */
			event.target.text = event.target.text.replace("*", "·");
			event.target.text = event.target.text.replace("-", "–");
			
			maskTextField();
		}
		
		private function keyUpHandler(event:KeyboardEvent):void
		{
			//trace("code: " + event.keyCode);
			switch (event.keyCode) 
			{
				case KeyCodes.LEFT_ARROW:
					if (_innerText.caretIndex == 0 && previousCaretIndex == _innerText.caretIndex)
						_myParent.moveFocus(this, "left");
					break;
				case KeyCodes.RIGHT_ARROW:
					if (_innerText.caretIndex == _innerText.length && previousCaretIndex == _innerText.caretIndex)
						_myParent.moveFocus(this, "right");
					break;
				case KeyCodes.BACKSPACE:
					if (_isCursorAtTheStartOnKeyDown && !SelectionManager.isElementsSelected) {
						_myParent.removePreviousItem(this);
						break;
					}
					
					deleteSelectedItems();
					break;
				case KeyCodes.DEL:
					if (_isCursorAtTheEndOnKeyDown && !SelectionManager.isElementsSelected) {
						_myParent.removeNextItem(this);
						break;
					}
					
					deleteSelectedItems();
					break;
				default:
					break;
			}
			
			previousCaretIndex = _innerText.caretIndex;
		}
		
		private function deleteSelectedItems():void
		{
			SelectionManager.instance.dispatchEvent(new Event(SelectionProcessEvent.DELETE_SELECTED));
		}
		
		/**
		 * This method changes focuse in FocusManager
		 * 
		 * @param	event
		 */
		private function mouseClickHandler(event:MouseEvent):void
		{
			SelectionManager.instance.dispatchEvent(new Event(CalculatorEvents.DESELECT));
			setFocus("center");
			// to coordinate caret position with arrow keys
			previousCaretIndex = _innerText.caretIndex;
		}
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			SelectionManager.instance.dispatchEvent(new SelectionProcessEvent("begin", this));
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			SelectionManager.instance.dispatchEvent(new SelectionProcessEvent("end", this));
		}
		
		private function mouseMoveHandler(event:MouseEvent):void
		{
			if (SelectionManager.selectionStatus == "is")
			{
				SelectionManager.instance.dispatchEvent(new SelectionProcessEvent("is", this));
			}
		}
		
		/**
		 * This method is used to set selection to the TextLeaf.
		 * It is similar to setSelection method of TextField.
		 * 
		 * @param	direction	shows the way of selection ("left", "right" or "all")
		 */
		public function setSelection(direction:String = "all"):void
		{
			_selected = true;
			if (direction == "all")
				_innerText.setSelection(0, _innerText.length);
			else
			{
				var indexAtPoint:int = _innerText.getCharIndexAtPoint(mouseX, mouseY);
				if (direction == "left")
				{
					if (indexAtPoint < 0 && mouseX > 0)
						indexAtPoint = _innerText.length;
					if (indexAtPoint < 0 && mouseX <= 0)
						indexAtPoint = 0;
					_innerText.setSelection(indexAtPoint, _innerText.length);
				}
				if (direction == "right")
				{
					if (indexAtPoint < 0 && mouseX <= 0)
						indexAtPoint = 0;
					if (indexAtPoint < 0 && mouseX > 0)
						indexAtPoint = _innerText.length;
					_innerText.setSelection(0, indexAtPoint + 1);
				}
			}
		}
		
		public function removeYourself(deleteMe:Object = null, forceDelete:Boolean = false):void 
		{
			if (!forceDelete && _innerText.selectedText != _innerText.text)
			{
				_innerText.replaceSelectedText("");
				return;
			}
			
			_innerText.removeEventListener(Event.CHANGE, textChangeHandler);
			_innerText.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
			this.removeEventListener(MouseEvent.CLICK, mouseClickHandler);
			
			// listeners for selection
			this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			this.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			
			_myParent.removeYourself(this);
		}
		
		/**
		 * Deselects all TextLeaf.
		 */
		public function clearSelection():void
		{
			_selected = false;
			// we mustn't setSelection in object that has focus
			if (stage.focus != _innerText)
				_innerText.setSelection(0, 0);
		}
		
		/**
		 * Puts the focus to this TextLeaf in specified place.
		 * 
		 * @param	position	where to put cursor ("left", "right", "center")
		 */
		public function setFocus(position:String):void 
		{
			stage.focus = _innerText;
			
			// set caret to the left or right side of the text
			// there are three positions: left, right and center (center is actual when user cliks on the field)
			if (position == "left") _innerText.setSelection(_innerText.length, _innerText.length)
			if (position == "right") _innerText.setSelection(0, 0);
			
			var focusHolder:TextLeaf = FocusManager.focusHolder;
			
			// decide to remove the selection or not
			if (focusHolder)
			{
				if (focusHolder.innerText.length == 0)
					focusHolder._innerText.background = focusHolder.showWhileEmpty;
				else
					focusHolder._innerText.background = false;
			}
			
			_innerText.background = true;
			
			// change focus in FocusManager
			FocusManager.focusHolder = this;
		}
		
		/**
		 * Returns an array of tokens that are in TextLeaf.
		 * For example: TextLeaf contains "1+0.55" the result is ["1", "+", "0.55"].
		 * 
		 * @return	array of tokens (Strings)
		 */
		public function getTokens():Array 
		{
			var tokens:Array = Parser.instance.lexicalParse(_innerText.text);
			
			if (tokens[0] == "error")
			{
				var errorMessage:String = T(tokens[1]);
				throw new Error( { "instance":this, "errorMessage":errorMessage } );
			}
				
			return tokens;
		}
		
		/**
		 * Use after changing of innerText.
		 */
		public function update():void
		{
			maskTextField();
		}
		
		// getters and setters
		public function get myParent():Object 
		{
			return _myParent;
		}
		
		public function set myParent(setValue:Object):void 
		{
			_myParent = setValue;
		}
		
		/**
		 * Link to the embedded TextField.
		 */
		public function get innerText():TextField
		{
			// call this method in order to prevent changing of TextField size 
			// without changing of mask
			maskTextField();
			return _innerText;
		}
		
		/**
		 * Highlight or not an empty TextLeaf.
		 */
		public function set showWhileEmpty(setValue:Boolean):void
		{
			_showWhileEmpty = setValue;
			if (_showWhileEmpty && _innerText.length == 0)
				{
					_innerText.background = _showWhileEmpty;
				}
		}
		
		/**
		 * Highlight or not an empty TextLeaf.
		 */
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
			_innerText.backgroundColor = _backgroundColor;
		}
		
		public function get backgroundColor():uint
		{
			return _backgroundColor;
		}
		
		/**
		 * If there more than ONE token in TextLeaf?
		 */
		public function isUnbreakable():Boolean
		{
			return Parser.instance.lexicalParse(_innerText.text).length == 1;
		}
		
		/**
		 * Return needed width of TextLeaf (the width of TEXT actually) in order
		 * to seal elements.
		 */
		override public function get width():Number 
		{
			// add RIGHTMARGIN to make good looking of text and it's background
			return _innerText.textWidth ? _innerText.textWidth + RIGHTMARGIN : EMPTYWIDTH;
		}
		
	}

}