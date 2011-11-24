package inobr.eft.formula.elements.main 
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.*;
	
	import inobr.eft.formula.core.managers.SelectionManager;
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.events.*;
	import inobr.eft.common.ui.DynamicSimpleButton;
	import inobr.eft.formula.core.managers.FocusManager;
	import inobr.eft.common.keyboard.*;
	
	/**
	 * Numeric variable element. Variable may have one value or a set of values.
	 * New variable will be made only if you put it on the Toolbar.
	 * use this code example:	
	 * 		Variable.getToolbarItem("k", [-3, -2, 0, 1])
	 * 
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class Variable extends BaseExpression 
	{
		private var _listForToolbar:Array = [];
		public var lable:String;
		public var value:Array;
		private var _variableText:TextField;
		
		// constants for suitable displaying
		private static const LEFTOFFSET:int = -3;
		private static const ADDITIONALWIDTH:int = 1;
		
		/**
		 * Numeric variable element.
		 * @param	_parent
		 * @param	nameAndValue	{lable:String, value:Array}
		 */
		public function Variable(_parent:Object, nameAndValue:Object = null) 
		{
			super(_parent);
			
			if(nameAndValue)
			{
				drawVariable(nameAndValue.name);
				this.lable = nameAndValue.name;
				this.value = nameAndValue.value;
			}
		}
		
		override protected function init(event:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			_myParent.moveFocus(this, "left");
			
			_variableText.addEventListener(MouseEvent.CLICK, clickOnVariableHandler);
			_variableText.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		/**
		 * Selection by click.
		 * @param	event
		 */
		private function clickOnVariableHandler(event:MouseEvent):void
		{
			if (_selected)
			{
				clearSelection();
				SelectionManager.instance.selectSpecifiedItems(null);
			}
			else
			{
				SelectionManager.instance.dispatchEvent(new Event(CalculatorEvents.DESELECT));
				setSelection();
				SelectionManager.instance.selectSpecifiedItems([this]);
			}
		}
		
		private function keyDownHandler(event:KeyboardEvent):void
		{
			if (_selected && (event.keyCode == KeyCodes.DEL ||
				event.keyCode == KeyCodes.BACKSPACE))
			{
				SelectionManager.instance.dispatchEvent(new Event(SelectionProcessEvent.DELETE_SELECTED));
			}
		}
		
		override public function setFocus(position:String):void 
		{
			if (position == "left")
			{
				if (_myParent != null)
					_myParent.moveFocus(this, "left");
			}
			else
			{
				if (_myParent != null)
					_myParent.moveFocus(this, "right");
			}
		}
		
		private function drawVariable(name:String):void
		{	
			_variableText = new TextField();
			var format:TextFormat = new TextFormat();
				format.font = "Tahoma";
				format.color = 0x990033;
				format.size = 20;
				format.bold = true;
				format.italic = true;
				
			_variableText.type = "dynamic";
			_variableText.background = false;
			_variableText.backgroundColor = 0x555555;
			// in order to full dispaly of italic characters
			_variableText.text = name + ' ';
			
			_variableText.autoSize = TextFieldAutoSize.LEFT;
			
			_variableText.setTextFormat(format);
			_variableText.defaultTextFormat = format;
			_variableText.selectable = false;
			
			_variableText.x = LEFTOFFSET;
			
			this.addChild(_variableText);
		}
		
		/**
		 * Returns button that will represent Power on the toolbar
		 * You can use library item or draw this button programmatically
		 * Recommended size of this button is 30x30
		 */
		public static function getToolbarItem(lable:String, value:*):SimpleButton
		{
			if (value is Number)
				var values:Array = [value];
			else
				values = value;
			var toolbarItem:SimpleButton = drawButton(lable);
			var nameAndValue:Object = new Object();
			nameAndValue.name = lable;
			nameAndValue.value = values;
			(toolbarItem as DynamicSimpleButton).nameAndValue = nameAndValue;
			
			toolbarItem.addEventListener(MouseEvent.CLICK, toolbarItemClicked);
			
			return toolbarItem;
		}
		
		private static function drawButton(lable:String):SimpleButton
		{
			var mainState:Sprite = new BaseVariableSprite();
			(mainState as MovieClip).variableName.text = lable;
			
			var toolbarButton:SimpleButton = new DynamicSimpleButton() as SimpleButton;
			
			toolbarButton.upState = mainState;
			toolbarButton.overState = mainState;
			toolbarButton.downState = mainState;
			toolbarButton.hitTestState = mainState;
			
			return toolbarButton;
		}
		
		private static function toolbarItemClicked(event:MouseEvent):void
		{
			// parameter of the AddNewElementEvent must be the name of Class
			FocusManager.instance.dispatchEvent(new AddNewElementEvent(Variable, event.target.nameAndValue));
		}
		
		override public function get centralLineY():uint
		{
			return this.height / 2;
		}
		
		override public function getValue():Array 
		{	
			var result:Array = [];
			var values:Array = getConstant(this.lable);
			for (var i:int = 0; i < values.length; i++) 
			{
				result[i] = String(values[i]);
			}
			
			return result;
		}
		
		override public function setSelection(direction:String = "all"):void
		{
			_selected = true;
			var format:TextFormat = new TextFormat();
				format.color = 0xFFFFFF;
			_variableText.setTextFormat(format);
			_variableText.background = true;
		}
		
		override public function clearSelection():void
		{
			_selected = false;
			var format:TextFormat = new TextFormat();
				format.color = 0x990033;
			_variableText.setTextFormat(format);
			_variableText.background = false;
		}
		
		/**
		 * If constantName is already exists this method will rewrite it
		 * with new value.
		 * 
		 * @param	constantName
		 * @param	value
		 */
		public function setConstant(constantName:String, value:*):void
		{
			if (value is Number)
				var values:Array = [value];
			else
				values = value;
			var newVar:Variable = new Variable(this);
			newVar.lable = constantName;
			newVar.value = values;
			_listForToolbar.push(newVar);
		}
		
		/**
		 * Delete specified constant. If there is no constant with such name
		 * return FALSE.
		 * 
		 * @param	constantName
		 * @return
		 */
		public function deleteConstant(constantName:String):Boolean
		{
			for (var i:int = 0; i < _listForToolbar.length; i++) 
			{
				if (_listForToolbar[i].lable == constantName)
				{
					_listForToolbar.splice(i, 1);
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Try to find specified constant and return its value. If there is no
		 * such constant returns NAN.
		 * 
		 * @param	constantName
		 * @return	the value of constant
		 */
		public function getConstant(constantName:String):Array
		{
			if (this.value)
				return this.value;
			else
				return null;
		}
		
		/*override public function setInnerElement(newElement:BaseExpression):void 
		{
			newElement.removeYourself();
			newElement = null;
		}
		
		override public function addListOfItems(list:Array):void
		{
			for (var i:int = 0; i < list.length; i++) 
			{
				list[i].removeYourself();
			}
			list.length = 0;
		}*/
		
		override public function isUnbreakable():Boolean
		{
			return true;
		}
		
		/**
		 * Return items for menu.
		 * @return	Array	list of items for toolbar
		 */
		public function get listForToolbar():Array
		{
			return _listForToolbar;
		}
		
		/**
		 * Return needed width of TextLeaf (the width of TEXT actually) in order
		 * to seal elements.
		 */
		override public function get width():Number 
		{
			return _variableText.textWidth - 2;
		}
	}

}