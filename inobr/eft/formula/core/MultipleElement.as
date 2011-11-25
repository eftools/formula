package inobr.eft.formula.core 
{
	import flash.events.*;
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.errors.CalculationError;
	import inobr.eft.formula.errors.ParserError;
	import inobr.eft.formula.events.*;
	import inobr.eft.formula.parser.Parser;
	
	/**
	 * ...
	 * @author gps
	 */
	public final class MultipleElement extends BaseExpression
	{	
		private var _scale:Number;
		
		/**
		 * An element that can include any number of other elements.
		 * Any element is a superposition of MultipleElements or SingleElements.
		 * Use this class to create your own element.
		 * See alse SingleElement.
		 * 
		 * @param	_parent		logical parent of item
		 * @param	scale		use Defaults to set scale
		 */
		public function MultipleElement(_parent:Object, scale:Number = 1):void
		{	
			super(_parent);
			
			scaleX = scale;
			scaleY = scale;
			_scale = scale;
			
			drawMultipleElement();
			
			backgroundColor = 0x6699FF;
			showWhileEmpty = true;
		}
		
		private function drawMultipleElement():void
		{	
			var leftTextLeaf:TextLeaf = new TextLeaf("");
			leftTextLeaf.myParent = this;
			
			// add new item to the list 
			_innerItems.push(leftTextLeaf);
			
			this.addChild(leftTextLeaf);
		}
		
		override protected function changed(event:Event):void
		{
			if (_innerItems.length == 0)
				return;
			
			var centralLine:uint = 0;
			
			for each (var item:Object in _innerItems) 
			{
				if (item is BaseExpression)
				{
					if (item.centralLineY > centralLine)
						centralLine = item.centralLineY;
				}
			}
			
			// calculate and gives new Y coordinate for all items
			if (centralLine == 0)
			{
				// we must "scale" the height of any inner item because it is scaled 
				// only in viewing and not in size!
				_innerItems[0].y = int(this.height / 2 - _innerItems[0].height * _scale / 2);
				_innerItems[0].x = 0;
				
				for (var i:int = 1; i < _innerItems.length; i++) 
				{
					_innerItems[i].y = this.height / 2 - _innerItems[i].height / 2;
					_innerItems[i].x = _innerItems[i - 1].x + _innerItems[i - 1].width;
				}
			}
			else
			{
				_innerItems[0].y = centralLine - _innerItems[0].height / 2;
				_innerItems[0].x = 0;
				
				for (i = 1; i < _innerItems.length; i++) 
				{
					if (_innerItems[i] is BaseExpression)
						_innerItems[i].y = centralLine - _innerItems[i].centralLineY;
					else
						_innerItems[i].y = centralLine - _innerItems[i].height / 2;
						
					_innerItems[i].x = _innerItems[i - 1].x + _innerItems[i - 1].width;
				}
			}
		}
		
		/**
		 * Trying to calculate this block and returns result or an error.
		 * 
		 * @return	result of calculation
		 */
		override public function getValue():Array 
		{
			var tokens:Array = [];
			var values:Object = {};
			// contain result of getValue() or getTokens()
			var nextExpression:Array = [];
			var varsCount:int = 0;
			var casesCount:int = 0;
			var result:Array = [];
			
			for (var i:int = 0; i < _innerItems.length; i++) 
			{
				if (_innerItems[i] is TextLeaf)
				{
					nextExpression = _innerItems[i].getTokens();
					if (nextExpression[0] == "")
						continue;
				}
				else
				{
					nextExpression = _innerItems[i].getValue();
					if (casesCount < nextExpression.length)
						casesCount = nextExpression.length;
					nextExpression.length = 0;
					nextExpression[0] = "@var";
					varsCount++;
				}
					
				// if there are two numbers in a row we put "·" between them
				var lastToken:String = tokens[tokens.length - 1];
				if(lastToken != null)
				{
					var collection:RegExp = /@var/;
					var lastIsNumber:Boolean = false;
					var nextIsNumber:Boolean = false;
					lastIsNumber = collection.test(lastToken) || !isNaN(Number(lastToken)) ? true : false;
					nextIsNumber = collection.test(nextExpression[0]) || !isNaN(Number(nextExpression[0])) ? true : false;
					
					if (lastIsNumber && nextIsNumber)
					{
						tokens.push("·");
						tokens = tokens.concat(nextExpression);
						if (_innerItems[i] is BaseExpression)
							values[tokens.lastIndexOf("@var")] = _innerItems[i].getValue();
						continue;
					}
				}
					
				tokens = tokens.concat(nextExpression);
				if(nextExpression[0] == "@var")
					values[tokens.lastIndexOf("@var")] = _innerItems[i].getValue();
			}
			
			// calculate array of values
			i = 0;
			do
			{
				for (var name:String in values) 
				{
					// if variable has only one value we use it in every case
					var currentValue:Number;
					if (values[name][i])
						currentValue = values[name][i];
					else
						currentValue = values[name][0];
						
					tokens.splice(int(name), 1, currentValue);
				}
				var RPN:Array = Parser.instance.convertInfixToRPF(tokens);
				result.push(Parser.instance.calculateRPF(RPN));
				i++;
			}
			while(i < casesCount)
			
			return result;
		}
		
		/**
		 * Return needed width of element in order to seal elements.
		 * Displayed width and true width are not the same because we
		 * need to mask some parts of TextLeaf.
		 */
		override public function get width():Number 
		{
			var customWidth:int = 0;
			for each (var item:Object in _innerItems) 
			{
				customWidth += item.width;
			}
			return (customWidth * _scale > 0) ? customWidth * _scale : 0;
		}

		/**
		 * Calculate specified formula (ComplexExpression) and returns 
		 * its values (set of values in common case) or throw Error if 
		 * there were any problems. Use this method with try...catch to 
		 * avoid errors!
		 * 
		 * @param	formula	
		 * @return	Array	
		 */
		public function Calculate():Array
		{
			// trying to calculate
			 // working with Number
			var resultString:Array = [];
			
			var resultNumber:Array = getValue();
			
			var precisionBase:Number = Math.pow(10 , FormulaWorkspace.precision);
			for (var i:int = 0; i < resultNumber.length; i++ ) 
			{
				resultNumber[i] = Math.round(resultNumber[i] * precisionBase) / precisionBase;
			}
			
			return resultNumber;
		}
	}

}