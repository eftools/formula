package inobr.eft.formula.elements.main 
{
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.events.*;
	import flash.utils.*;
	
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.events.*;
	import inobr.eft.formula.core.managers.FocusManager;
	import inobr.eft.common.lang.*;
	
	/**
	 * Fraction class is used for working with fraction in formula box.
	 * 
	 * @author	Artyom Philonenko <greshnikk@gmail.com>
	 */
	public class Fraction extends BaseExpression
	{
		/**
		 * Line between numerator and denominator
		 */
		private var _fractionLine:Shape;
		
		/**
		 * Argument above fraction line
		 */
		private var _fractionNumerator:MultipleElement;
		
		/**
		 * Argument under fraction line
		 */
		private var _fractionDenominator:MultipleElement;
		
		/**
		 * Thickness of line between numerator and denumerator
		 */
		private const LINE_THICKNESS:Number = 2;
		
		/**
		 * Fraction object initialization.
		 * 
		 * @param	_parent	Object, for which, this object is an argument
		 */
		public function Fraction(_parent:Object):void
		{
			super(_parent);
			
			drawFunction();
		}
		
		/**
		 * Initially draws function in the formula box.
		 */
		protected function drawFunction():void 
		{
			_fractionNumerator = new MultipleElement(this);
			_fractionDenominator = new MultipleElement(this);
			addElement(_fractionNumerator);
			addElement(_fractionDenominator);
			
			changed(null);
		}
		
		/**
		* Redraws all dynamic elements according to their width and height.
		* 
		* @param	event	Event that activates this method
		*/
		override protected function changed(event:Event):void 
		{			
			_fractionNumerator.x = this.width / 2 - _fractionNumerator.width / 2;
			_fractionNumerator.y = 0;
			_fractionDenominator.x = this.width / 2 - _fractionDenominator.width / 2;
			_fractionDenominator.y = _fractionNumerator.y + _fractionNumerator.height + LINE_THICKNESS;
			 
			try
			{
				this.removeChild(_fractionLine);
			}
			catch (error:Error) { }
			
			_fractionLine = new Shape();			
			_fractionLine.graphics.lineStyle(LINE_THICKNESS, 0x000000);
			_fractionLine.graphics.moveTo(0, _fractionNumerator.y + _fractionNumerator.height);
			_fractionLine.graphics.lineTo(this.width, _fractionNumerator.y + _fractionNumerator.height);
			this.addChild(_fractionLine);
		}
			
		/**
		 * Returns the Y coordinate of fraction line
		 * This value is used to center all items round the fraction line
		 */
		override public function get centralLineY():uint
		{
			return _fractionNumerator.height;
		}
		
		/**
		 * Returns button that will represent Fraction on the toolbar
		 * You can use library item or draw this button programmatically
		 * Recommended size of this button is 30x30
		 */
		public static function getToolbarItem():SimpleButton
		{
			var toolbarItem:SimpleButton = new AddFractionButton();
			
			toolbarItem.addEventListener(MouseEvent.CLICK, toolbarItemClicked);
			
			
			return toolbarItem;
		}
		
		private static function toolbarItemClicked(event:MouseEvent):void
		{
			// parameter of the AddNewElementEvent must be the name of Class
			FocusManager.instance.dispatchEvent(new AddNewElementEvent(Fraction));
		}
		
		/**
		 * Calculates function for all input arguments.
		 * 
		 * @return	array of calculated function values
		 */
		override public function getValue():Array 
		{
			var numerator:Array = _fractionNumerator.getValue();
			var denominator:Array = _fractionDenominator.getValue();
			
			var result:Array = [];
			
			if (numerator[0] == "NaN" || denominator[0] == "NaN")
			{
				var errorMessage:String = T('NoArgument');
				throw new Error( { "instance":this, "errorMessage":errorMessage } );	
			}
			var valuesNum:int = Math.max(numerator.length, denominator.length);
			for (var i:int = 0; i < valuesNum; i++) 
			{
				var d:int;
				var n:int;
				numerator[i] ? n = i : n = 0;
				denominator[i] ? d = i : d = 0;
				
				if (Number(denominator[d]) == 0)
				{
					errorMessage = T('DivisionByZero');
					throw new Error( { "instance":this, "errorMessage":errorMessage } );
				}
				var fraction:Number = Number(numerator[n]) / Number(denominator[d]);
					
				result[i] = String(fraction);
			}
				
			return result;
		}
		
		/**
		 * Return needed width of element. TextLeaf is displayed in cropped way so 
		 * default width property of DisplayObject will return NOT actual value.
		 */
		override public function get width():Number 
		{	
			return Math.max(_fractionDenominator.width, _fractionNumerator.width);
		}
	}

}