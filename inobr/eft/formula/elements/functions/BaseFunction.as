package inobr.eft.formula.elements.functions 
{
	import flash.display.Shape;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.*;
	
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.events.*;
	
	
	/**
	 * The BaseFunction class is used as parent for any function class.
	 * 
	 * @author	Artyom Philonenko <greshnikk@gmail.com>
	 */	
	public class BaseFunction extends BaseExpression
	{
		/**
		 * Function argument
		 */
		protected var _argument:MultipleElement;
		
		/**
		 * Function pow. Function can have no pow.
		 */
		protected var _pow:MultipleElement;
		
		/**
		 * Function index/base.
		 * Function can have no index. @see BaseFunctionWithoutIndex
		 */
		protected var _index:MultipleElement;
		
		/**
		 * Function name. For example, sin.
		 */
		protected var _text:TextField;
		
		/**
		 * Autosized left bracket for argument
		 */
		protected var _leftBracket:Shape;
		
		/**
		 * Autosized right bracket for argument
		 */
		protected var _rightBracket:Shape;
		
		/**
		 * Margin between _text and pow or _text and index
		 */
		private const POW_MARGIN:Number = 0;

		/**
		 * Margin between maximum of pow width and index width and left bracket
		 */
		private const BRACKET_MARGIN:Number = 3;
		
		/**
		 * Margin between bracket and argument
		 */
		private const ARGUMENT_MARGIN:Number = 2;
		
		public function BaseFunction(_parent:Object)
		{
			super(_parent);
		}
		
		/**
		 * Initially draws function in the formula box.
		 * 
		 * @param	text	Function name
		 */
		protected function drawFunction(text:String):void
		{
			_text = new TextField();				
			_text.type = "dynamic";
			_text.text = text;			
			_text.autoSize = TextFieldAutoSize.LEFT;						
			_text.setTextFormat(Defaults.TEXT_SETTINGS);
			_text.defaultTextFormat = Defaults.TEXT_SETTINGS;
			_text.selectable = false;
			
			addChild(_text);						
			addPow();
			addArgument();
			addIndex();	
			
			changed(null);
		}
		
		/**
		* Redraws all dynamic elements according to their width and height.
		* 
		* @param	event	Event that activates this method
		*/
		override protected function changed(event:Event):void
		{
			var powHeight:Number = 0;			
			if (_pow)
			{
				powHeight = _pow.height;
			}
			
			// Calculate pow and argument y coordinates, according to the
			// element with the most higher height value
			if (powHeight + MarginFromTextCenter() > _argument.height / 2)
			{
				_pow.y = 0;
				_argument.y = powHeight + MarginFromTextCenter() - _argument.height / 2;
			}
			else
			{
				_argument.y = 0;
				_pow.y = _argument.height / 2 - MarginFromTextCenter() - powHeight;
			}			
			
			// Aligning _text center to _argument center
			_text.y = _argument.y + _argument.height / 2 - _text.height / 2;
			
			if (_index)
				_index.y = _text.y + _text.height / 2 + MarginFromTextCenter();				
			try
			{
				removeChild(_leftBracket);
				removeChild(_rightBracket);
			}
			catch (error:Error) { }			
			
			addChild(_leftBracket = drawBracket('left'));
			_argument.x = _leftBracket.x + _leftBracket.width + ARGUMENT_MARGIN;
			addChild(_rightBracket = drawBracket('right'));
		}
		
		/**
		 * Calculates range between coordinate, where pow ends
		 * (1 / 3 of text height), and middle of text height (1 / 2)
		 * 1 / 2 - 1 / 3 = 1 / 6
		 * 
		 * @return	range as number
		 */
		private function MarginFromTextCenter():Number
		{
			return _text.height / 6;
		}
		
		/**
		 * Adds index element to the formula box.
		 */
		protected function addIndex():void
		{
			_index = new MultipleElement(this, Defaults.SCALE);
			_index.x = _text.x + _text.width + POW_MARGIN;
			addElement(_index);
		}
		
		/**
		 * Adds pow element to the formula box.
		 */
		protected function addPow():void
		{
			_pow = new MultipleElement(this, Defaults.SCALE);			
			_pow.x = _text.x + _text.width + POW_MARGIN
			_pow.y = 0;
			addElement(_pow);		
		}
		
		/**
		 * Adds argument element to the formula box.
		 */
		protected function addArgument():void
		{
			_argument = new MultipleElement(this);
			addElement(_argument);
		}
		
		/**
		 * Draws and position a bracket according to the parameter.
		 * 
		 * @param	side	'left' or 'right', according to the bracket
		 * @return	created bracket, as Shape
		 */
		protected function drawBracket(side:String):Shape
		{					
			var bracket:Shape = new Shape();
			var warpRatio:Number = Math.round(_argument.height * 0.1);
			
			bracket.graphics.lineStyle(2, 0x000000);
			if (side == 'left')
			{
				// Bracket.x returns X coordinate of control point.
				// bracket.width returns us shape width, that does NOT include
				// control point. So, if we want to add new object, after
				// this bracket, we can't use bracket.x + bracket.width!
				// One of the solves is to draw control point in negative
				// coordinate. So instead of using from 0 to warpRatio, we use
				// from -warpRatio / 2 to warpRatio / 2.
				// But, why are we using just warpRatio / 2 ?
				// It's beacause method curveTo draws a Bezier curve, and
				// range between control point and first point is equal the
				// range between control point and second point. So our
				// bracket X coordinate will be exactly in the middle
				// i.e. warpRatio / 2.
				bracket.graphics.moveTo(warpRatio / 2, 0);
				bracket.graphics.curveTo(-warpRatio / 2, _argument.height / 2, warpRatio / 2, _argument.height);								
				bracket.x = Math.round(_pow.x + Math.max(_pow.width, _index ? _index.width : 0) + BRACKET_MARGIN);
			}
			else
			{
				bracket.graphics.moveTo(0, 0);
				bracket.graphics.curveTo(warpRatio, _argument.height / 2, 0, _argument.height);
				bracket.x = Math.round(_argument.x + _argument.width + ARGUMENT_MARGIN);
			}
			
			bracket.y = _argument.y;
			
			return bracket;
		}
		
		override public function get centralLineY():uint
		{
			return _argument.centralLineY  + _argument.y;
		}
	}
}