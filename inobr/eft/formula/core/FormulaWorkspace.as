package inobr.eft.formula.core
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.core.checkers.*;
	import inobr.eft.formula.elements.functions.*;
	import inobr.eft.formula.elements.main.*;
	import inobr.eft.formula.events.CalculatorEvents;
	import inobr.eft.common.ui.*;
	import inobr.eft.common.lang.*;
	
	/**
	 * This class draw all basic items of Formula such as:
	 * 1) Panel of instruments - toolbar (expressions, predefined variables)
	 * 2) Formula Area (where we can put formulas)
	 * 3) Additional tools panel (not activated by default)
	 * 
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class FormulaWorkspace extends Sprite 
	{	
		private var _allFormulas:Array /* of Sprites */ = [];
		// main container
		private var _calculator:Sprite = new Sprite();
		
		private var _toolbar:Toolbar;
		private var _formulaArea:Sprite = new Sprite();
		private var _scrollArea:GScrollPane;
		private var _addFormulaButton:SimpleButton;
		private var _addFinalFormulaButton:SimpleButton;
		
		private var _formulaAreaType:String = FormulaAreaTypes.CHECK;
		
		private var baseFormat:BlockFormat;
		private var formulaAreaFormat:BlockFormat;
		
		private var _setWidth:uint;
		private var _setHeight:uint;
		
		// precision of calculated result
		private static var _precision:Number = 3;
		private var _checkers:Array = [];
		
		/**
		 * Creates formula workspace with toolbar, formula area, formuala boxes
		 * and formulas.
		 * 
		 * @param	width	the width of workspace in pixels
		 * @param	height	the height of workspace in pixels
		 * @param	lang	used language
		 * @param	baseFormat	
		 * @param	formulaAreaFormat
		 */
		public function FormulaWorkspace(width:uint, height:uint, lang:Object,
										baseFormat:BlockFormat = null,
										formulaAreaFormat:BlockFormat = null):void 
		{
			// default margin
			this.x = 10;
			
			_setWidth = width;
			_setHeight = height;
			
			// forming Toolbar and it's format
			var toolBarFormat:BlockFormat = new BlockFormat();
				toolBarFormat.blockFill = 0x729FDC;
			_toolbar = new Toolbar(40, toolBarFormat);
			
			// if there no formats use default
			this.baseFormat = baseFormat ? baseFormat : new BlockFormat();
			this.formulaAreaFormat = formulaAreaFormat ? formulaAreaFormat : new BlockFormat();
			
			// add behaviour
			addEventListener(Event.CHANGE, changed);
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			Lang.Init(lang);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			// form main container (set WIDTH and HEIGHT)
			formCalculator(_setWidth, _setHeight);
			
			// create moduls of calculator
			_toolbar.x = baseFormat.marginHorizontal;
			_toolbar.y = baseFormat.marginVertical;
			_toolbar.resizeToolbar(_calculator.width - baseFormat.marginHorizontal * 2, _toolbar.height);
			addFormulaArea();
			
			_calculator.addChild(_toolbar);
			
			// add calculator to the display list
			this.addChild(_calculator);
		}
		
		private function formCalculator(width:uint, height:uint):void
		{	
			var calculatorBody:Shape = new Shape();
			calculatorBody.graphics.beginFill(baseFormat.blockFill);
			calculatorBody.graphics.lineStyle(baseFormat.borderWidth, baseFormat.borderColor);
			calculatorBody.graphics.drawRect(0, 0, width, height);
			calculatorBody.graphics.endFill();
			
			_calculator.addChild(calculatorBody);
		}
		
		private function addFormulaArea():void
		{	
			// insert first formula into formulaArea
			insertFormula();
			// insert button that can add new formula
			insertAddButton();
			_calculator.addChild(_formulaArea);
			
			// add scrolling. Remember that you set size of VISIBLE area
			// if contant becomes grater than visible area scrollbars will be added 
			_scrollArea = new GScrollPane(_calculator.width - baseFormat.marginHorizontal * 2 - baseFormat.borderWidth,
										 _calculator.height - _toolbar.height - baseFormat.marginVertical * 3 - 2*baseFormat.borderWidth,
										 formulaAreaFormat);
			_scrollArea.x = baseFormat.marginHorizontal;
			_scrollArea.y = _toolbar.y + _toolbar.height + baseFormat.marginVertical; 
			
			_scrollArea.content = _formulaArea;
			_scrollArea.updateScroll();
			
			_calculator.addChild(_scrollArea);
		}
		
		private function insertFormula():void
		{
			var mode:String;
			var removable:Boolean;
			switch (_formulaAreaType) 
			{
				case FormulaAreaTypes.SINGLE_CALCULATE:
					mode = FormulaBox.CALCULATE_MODE;
					removable = false;
				break;
				
				case FormulaAreaTypes.CHECK:
					mode = FormulaBox.CHECK_MODE;
					removable = false;
				break;
				
				case FormulaAreaTypes.MULTIPLE_CALCULATE:
					mode = FormulaBox.CALCULATE_MODE;
					removable = true;
				break;
				
				default:
					
				break;
			}
			var formula:FormulaBox = new FormulaBox(this, mode, removable);
			
			if(_allFormulas.length == 0)
				formula.y = 0;
			else
				formula.y = _allFormulas[_allFormulas.length - 1].y +
							_allFormulas[_allFormulas.length - 1].height + formulaAreaFormat.marginVertical;
				
			// we must set Width and myParent of each formula
			formula.setWidth(_setWidth - baseFormat.marginHorizontal * 2 - formulaAreaFormat.marginHorizontal * 2 - 1.5*formulaAreaFormat.borderWidth);
			
			_formulaArea.addChild(DisplayObject(formula));
			
			// add new formula to the list
			_allFormulas.push(formula);
		}
		
		private function insertAddButton():void
		{
			if (_formulaAreaType != FormulaAreaTypes.MULTIPLE_CALCULATE)
				return;
				
			// this button adds new intermediate formula
			_addFormulaButton = new AddNewFormulaButton();
			
			var Y:int = _allFormulas[_allFormulas.length - 1].y +
						_allFormulas[_allFormulas.length - 1].height + formulaAreaFormat.marginVertical;
			_addFormulaButton.x = _formulaArea.width / 2 - _addFormulaButton.width - formulaAreaFormat.marginHorizontal / 2;
			_addFormulaButton.y = Y;
				
			_formulaArea.addChild(_addFormulaButton);
			
			// this button adds new final formula
			_addFinalFormulaButton = new AddNewFinalFormulaButton();
			
			_addFinalFormulaButton.x = _formulaArea.width / 2 + formulaAreaFormat.marginHorizontal / 2;
			_addFinalFormulaButton.y = Y;
				
			_formulaArea.addChild(_addFinalFormulaButton);
			
			// add CLICK listeners for our buttons
			_addFormulaButton.addEventListener(MouseEvent.CLICK, addFormulaPressed);
			//_addFormulaButton.addEventListener(MouseEvent.CLICK, addFormulaPressed);
		}
		
		private function addFormulaPressed(event:MouseEvent):void
		{
			insertFormula();
			// after adding new formula we must update positions of all the items
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function changed(event:Event):void
		{
			// first formula has hard-coded Y-coordinate, that specifide by _marginWidth
			if (_allFormulas[0])
				_allFormulas[0].y = 0;
			else // if there is no more any formulas we must shift only buttons
			{
				_addFormulaButton.y = 0;
				_addFinalFormulaButton.y = 0;
				return;
			}
			
			for (var i:int = 1; i < _allFormulas.length; i++) 
			{
				_allFormulas[i].y = _allFormulas[i - 1].y + _allFormulas[i - 1].height + formulaAreaFormat.marginVertical;
			}
			
			try 
			{
				var Y:int = _allFormulas[_allFormulas.length - 1].y +
							_allFormulas[_allFormulas.length - 1].height + formulaAreaFormat.marginVertical;
				_addFormulaButton.y = Y;
				_addFinalFormulaButton.y = Y;
			} 
			catch (err:Error) {/* nothing to do because there are no buttons */}
			// after all changes we MUST call updateScroll() method of our 
			// scrollArea
			_scrollArea.updateScroll();
		}
		
		public function removeItem(deleteMe:FormulaBox):void
		{
			for (var i:int = 0; i < _allFormulas.length; i++) 
			{
				if (_allFormulas[i] == deleteMe)
				{
					_allFormulas.splice(i, 1);
					break;
				}
			}
			
			_formulaArea.removeChild(deleteMe);
			
			// after adding new formula we must update positions of all the items
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		// getters and setters
		
		/**
		 * Returns the user-defined precision of calculations (number of
		 * digits after the decimal point).
		 */
		public static function get precision():Number
		{
			return _precision
		}
		
		/**
		 * Set precision of calculations. The default value is "3"
		 * (for example: the result is "0.123456" and precision is "2" 
		 * you will see "0.12" in the answer).
		 * @param	setValue number of digits after the decimal point
		 */
		public static function set precision(setValue:Number):void
		{
			if (setValue > 0)
				_precision = setValue;
		}
		
		/**
		 * Sets the configuration of formula area and formula boxes tools. 
		 * Acceptable values for the FormulaAreaTypes constants.
		 */
		public function set formulaAreaType(setValue:String):void
		{
			_formulaAreaType = setValue;
		}
		
		/**
		 * Add new checker for calculator. 
		 * The order of addition of checkers matches the order of their execution.
		 * For common cases you can use CheckByValues.
		 * 
		 * @param	checker	any IChecker implementation
		 */
		public function addChecker(checker:IChecker):void
		{
			_checkers.push(checker);
		}
		
		/**
		 * Array of checkers (implementations of IChecker interface).
		 */
		public function get checkers():Array
		{
			return _checkers;
		}
		
		public function get toolbar():Toolbar
		{
			return _toolbar;
		}
	}
	
}