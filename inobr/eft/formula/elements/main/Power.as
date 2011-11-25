package inobr.eft.formula.elements.main 
{
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.events.*;
	import flash.utils.*;
	
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.events.*;
	import inobr.eft.formula.parser.Parser;
	import inobr.eft.formula.core.managers.FocusManager;
	import inobr.eft.formula.errors.CalculationError;
	import inobr.eft.common.lang.*;
	
	/**
	 * Power element.
	 * 
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class Power extends BaseExpression 
	{
		private var _base:BaseExpression;
		private var _index:MultipleElement;
		private var MARGIN:Number = 0;
		
		private var _leftBracket:Shape;
		private var _rightBracket:Shape;
		
		/**
		 * Power element.
		 * 
		 * @param	_parent
		 */
		public function Power(_parent:Object):void
		{
			super(_parent);
			
			drawPower();
		}
		
		private function drawPower():void
		{
			_base = new SingleElement(this);
			_index = new MultipleElement(this, Defaults.SCALE);
			
			_index.showWhileEmpty = true;
			_base.x = MARGIN;
			_index.x = _base.x + _base.width + MARGIN;
			_base.y = _index.height / 2;

			_innerItems.push(_base);
			_innerItems.push(_index);
			
			this.addChild(_base);
			this.addChild(_index);
		}
		
		override protected function changed(event:Event):void
		{
			_index.x = _base.x + _base.width + MARGIN;
			_base.y = _index.height / 2;
		}
		
		/**
		 * Returns button that will represent Power on the toolbar
		 * You can use library item or draw this button programmatically
		 * Recommended size of this button is 30x30
		 */
		public static function getToolbarItem():SimpleButton
		{
			var toolbarItem:SimpleButton = new AddPowerButton();
			
			toolbarItem.addEventListener(MouseEvent.CLICK, toolbarItemClicked);
			
			return toolbarItem;
		}
		
		private static function toolbarItemClicked(event:MouseEvent):void
		{
			// parameter of the AddNewElementEvent must be the name of Class
			FocusManager.instance.dispatchEvent(new AddNewElementEvent(Power));
		}
		
		override public function get centralLineY():uint
		{
			return _base.height / 2 + _index.height / 2;
		}
		
		override public function getValue():Array 
		{
			var base:Array = _base.getValue();
			var index:Array = _index.getValue();
			var result:Array = [];
			
			if (base[0] == "NaN" || index[0] == "NaN")
			{
				throw new CalculationError(T('NoArgument'), this);	
			}
			
			var valuesNum:int = Math.max(base.length, index.length);
			for (var i:int = 0; i < valuesNum; i++) 
			{
				var b:int;
				var p:int;
				base[i] ? b = i : b = 0;
				index[i] ? p = i : p = 0;
				
				var value:Number = Math.pow(base[b], index[p]);
				result[i] = String(value);
			}
			
			return result;
		}
		
		/**
		 * Insert list of items in element.
		 * @param	list	of items to be inserted
		 */
		override public function addListOfItems(list:Array):void
		{
			/* if 
			 * 	there is only one unbreakable element is coming we put it 
			 * 	in the _base
			 * else
			 * 	we put income element into Brackets and change the _base
			 */ 
			if (list.length == 1 && list[0].isUnbreakable())
			{
				if (list[0] is TextLeaf)
					_base.innerItems[0].innerText.text = list[0].innerText.text;
				else
				{
					list[0].myParent = _base;
					list[0].x = 0;
					list[0].y = 0;
					_base.setInnerElement(list[0]);
				}
			}
			else
			{
				_base.setInnerElement(new Brackets(_base));
				_base.innerItems[0].addListOfItems(list);
			}
		}
		
		/**
		 * Return real width (because as DisplayObject Power has unreal width
		 * of displayed part). Base width + index width.
		 */
		override public function get width():Number 
		{
			return _base.width + _index.width;
		}
	}

}