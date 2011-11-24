package inobr.eft.formula.elements.main 
{
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.events.*;

	import inobr.eft.formula.core.BaseExpression;
	import inobr.eft.formula.core.MultipleElement;
	import inobr.eft.formula.events.*;
	import inobr.eft.formula.core.managers.FocusManager;
	
	/**
	 * Brackets element.
	 * 
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class Brackets extends BaseExpression 
	{
		private var expression:MultipleElement;
		private var _leftBracket:Shape;
		private var _rightBracket:Shape;
		/**
		 * Margin between bracket and argument
		 */
		private const ARGUMENT_MARGIN:Number = 2;
		
		/**
		 * Brackets element.
		 * 
		 * @param	_parent
		 */
		public function Brackets(_parent:Object) 
		{
			super(_parent);
			
			expression = new MultipleElement(this);
			_innerItems.push(expression);
			this.addChild(expression);
			changed(null);
		}
		
		/**
		* Redraws all dynamic elements according to their width and height.
		* 
		* @param	event	Event that activates this method
		*/
		override protected function changed(event:Event):void
		{
			try
			{
				removeChild(_leftBracket);
				removeChild(_rightBracket);
			}
			catch (error:Error) { }			
			
			addChild(_leftBracket = drawBracket('left'));
			expression.x = _leftBracket.x + _leftBracket.width + ARGUMENT_MARGIN;
			addChild(_rightBracket = drawBracket('right'));
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
			var warpRatio:Number = Math.round(expression.height * 0.1);
			
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
				bracket.graphics.curveTo(-warpRatio / 2, expression.height / 2, warpRatio / 2, expression.height);
			}
			else
			{
				bracket.graphics.moveTo(0, 0);
				bracket.graphics.curveTo(warpRatio, expression.height / 2, 0, expression.height);
				bracket.x = Math.round(expression.x + expression.width + ARGUMENT_MARGIN);
			}
			
			bracket.y = expression.y;
			
			return bracket;
		}
		
		/**
		 * Returns button that will represent Brackets on the toolbar
		 * You can use library item or draw this button programmatically
		 * Recommended size of this button is 30x30
		 */
		public static function getToolbarItem():SimpleButton
		{
			var toolbarItem:SimpleButton = new AddBracketsButton();
			
			toolbarItem.addEventListener(MouseEvent.CLICK, toolbarItemClicked);
			
			return toolbarItem;
		}
		
		private static function toolbarItemClicked(event:MouseEvent):void
		{
			// parameter of the AddNewElementEvent must be the name of Class
			FocusManager.instance.dispatchEvent(new AddNewElementEvent(Brackets));
		}
		
		override public function getValue():Array
		{
			return expression.getValue();
		}
		
		override public function get centralLineY():uint
		{
			return expression.height / 2;
		}
		
		override public function isUnbreakable():Boolean
		{
			return true;
		}
	}

}