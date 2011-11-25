package inobr.eft.formula.elements.main 
{
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.events.*;
	import flash.utils.*;
	
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.core.managers.FocusManager;
	import inobr.eft.formula.events.*;
	import inobr.eft.formula.errors.CalculationError;
	import inobr.eft.common.lang.*;
	
	/**
	 * ...
	 * @author Artyom Philonenko (greshnikk@gmail.com)
	 */
	public class Root extends BaseExpression 
	{
		private var _power:MultipleElement;
		private var _radicant:MultipleElement;
		
		private var _lines:Array = [];
		
		private const _lineThickness:Number = 2;
		private const _lineColor:uint = 0x000000; //black
		private const MARGIN:int = 3;
		private const LINES_MARGIN:int = 9;
		
		public function Root(_parent:Object):void
		{
			super(_parent);			
			
			//Saving our arguments:
			_radicant = new MultipleElement(this);
			_innerItems.push(_radicant);
			
			_power = new MultipleElement(this, Defaults.SCALE);
			_innerItems.push(_power);
			
			drawRoot();						
		}
		
		private function drawRoot():void
		{
			_power.x = 0;
			_power.y = 0;
			
			changed(null);
			//other option of ising this method:
			//dispatchEvent(new Event(Event.CHANGE));
			
			this.addChild(_radicant);			
			this.addChild(_power);			
		}
		
		override protected function changed(event:Event):void
		{
			_radicant.x = _power.x + _power.width + LINES_MARGIN;
			_radicant.y = _power.y + _power.height / 2 + MARGIN;
			//Removing old lines //width = <====>
			try
			{
				for (var i:int = 0; i < 4; ++i)
				{
					this.removeChild(_lines[i]);
				}
			}
			catch (error:Error) { }
			
			_lines[0] = new Shape();
			_lines[0].graphics.lineStyle(_lineThickness, _lineColor);
			_lines[0].graphics.moveTo(_power.x,
									_power.y + _power.height + MARGIN);
			_lines[0].graphics.lineTo(_power.x + _power.width + MARGIN,
									_power.y + _power.height + MARGIN);
			
			_lines[1] = new Shape();
			_lines[1].graphics.lineStyle(_lineThickness, _lineColor);
			_lines[1].graphics.moveTo(_power.x + _power.width + MARGIN,
									_power.y + _power.height + MARGIN);
			_lines[1].graphics.lineTo(_radicant.x - LINES_MARGIN / 2,
									_radicant.y + _radicant.height + MARGIN);
			
			_lines[2] = new Shape();
			_lines[2].graphics.lineStyle(_lineThickness, _lineColor);
			_lines[2].graphics.moveTo(_radicant.x - LINES_MARGIN / 2,
									_radicant.y + _radicant.height + MARGIN);
			_lines[2].graphics.lineTo(_radicant.x,
									_radicant.y - MARGIN);
			
			_lines[3] = new Shape();
			_lines[3].graphics.lineStyle(_lineThickness, _lineColor);
			_lines[3].graphics.moveTo(_radicant.x,
									_radicant.y - MARGIN);
			_lines[3].graphics.lineTo(_radicant.x + _radicant.width + MARGIN,
									_radicant.y - MARGIN);
			
			for (i = 0; i < 4; ++i)
			{
				this.addChild(_lines[i]);
			}
		}
		
		public static function getToolbarItem():SimpleButton
		{
			var toolbarItem:SimpleButton = new AddRootButton();
			
			toolbarItem.addEventListener(MouseEvent.CLICK, toolbarItemClicked);
			
			
			return toolbarItem;
		}
		
		private static function toolbarItemClicked(event:MouseEvent):void
		{
			// parameter of the AddNewElementEvent must be the name of Class
			FocusManager.instance.dispatchEvent(new AddNewElementEvent(Root));
		}

		override public function get centralLineY():uint
		{
			return _radicant.y + _radicant.height / 2;
		}
		
		override public function getValue():Array 
		{
			var result:Array = [];
			var argumentValues:Array = _radicant.getValue();
			var powValues:Array = _power.getValue();
			if (isNaN(powValues[0]))
				powValues[0] = 2;
			
			if (argumentValues[0] == "NaN")
			{
				throw new CalculationError(T('NoArgument'), this);	
			}
			var valuesNum:int = Math.max(argumentValues.length, powValues.length);
			for (var i:int = 0; i < valuesNum; i++) 
			{
				if (argumentValues[i] < 0)
				{
					throw new CalculationError(T('NegativeNumberUnderRoot'), this);
				}
				
				if (powValues[i] == 0)
				{
					throw new CalculationError(T('ZeroNumberInRootPow'), this);
				}
				
				var a:int;
				var p:int;
				argumentValues[i] ? a = i : a = 0;
				powValues[i] ? p = i : p = 0;
				
				var value:Number = Math.pow(argumentValues[a], 1 / powValues[p]);
				result[i] = String(value);
			}	
			
			return result;
		}	
		
	}

}