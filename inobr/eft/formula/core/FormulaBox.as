package inobr.eft.formula.core 
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.*;
	import inobr.eft.formula.errors.*;
	
	import inobr.eft.formula.events.*;
	import inobr.eft.formula.core.FormulaWorkspace;
	import inobr.eft.common.ui.NotificationWindow;
	import inobr.eft.common.lang.*;
	
	
	/**
	 * This is container for single formula in the formula workspace.
	 * Provides the user with tools for working with a formula as a whole element
	 * (deleting, checking, calculating, adding new one).
	 * 
	 * @author Peter Gerasimenko (gpstmp@gmail.com)
	 */
	public class FormulaBox extends Sprite 
	{
		private static var _maxWidth:uint = 0;
		public static const CHECK_MODE:String = "checkMode";
		public static const CALCULATE_MODE:String = "calculateMode";
		private static const PADDING:uint = 5;
		private static const SIDEPANELWIDTH:uint = 12;
		
		private var _borderColor:uint = 0x000000;
		private var _fillColor:uint   = 0xFFC000;
		
		private var _formulaBox:Sprite = new Sprite();
		private var _box:Shape;
		
		private var _currentWidth:uint = 0;
		private var _formula:MultipleElement;
		
		private var _sidePanel:Sprite = new Sprite();
		private var _sidePanelFillColor:uint   = 0xFFFFFF;
		private var _sidePanelBorderColor:uint = 0x000000;
		
		private var _deleteFormulaButton:SimpleButton;
		private var _calculateFormulaButton:SimpleButton;
		private var _checkFormulaButton:SimpleButton;
		
		private var _myParent:FormulaWorkspace;
		private var _mode:String;
		private var _removable:Boolean;
		
		public function FormulaBox(_parent:FormulaWorkspace, mode:String, removable:Boolean):void
		{
			_myParent = _parent;
			_mode = mode;
			_removable = removable;
			
			drawFormulaBox();
			addEventListener(Event.CHANGE, changed);
		}
		
		private function changed(event:Event):void
		{
			changeSize();
		}
		
		private function drawFormulaBox():void
		{
			this.addChild(_formulaBox);
			var formulaBox:Shape = new Shape();
			formulaBox.graphics.beginFill(_fillColor);
			formulaBox.graphics.lineStyle(1, _borderColor);
			// 10, 10 is not magic: later formulaBox will be redrawn with normal size
			formulaBox.graphics.drawRect(0, 0, 10, 10);
			formulaBox.graphics.endFill();
			
			_box = formulaBox;
			
			_formulaBox.addChild(formulaBox);
			
			// insert formula in formula box
			addFormula();
		}
		
		private function addFormula():void
		{
			var basicLeaf:MultipleElement = new MultipleElement(this);
			basicLeaf.x = PADDING;
			basicLeaf.y = PADDING;
			
			basicLeaf.showWhileEmpty = true;
			
			_formula = basicLeaf;
			
			_formulaBox.addChild(DisplayObject(basicLeaf));
		}
		
		private function addSidePanel():void
		{
			_sidePanel.x = _maxWidth - SIDEPANELWIDTH;
			_formulaBox.addChild(_sidePanel);
			
			var listOfTools:Array = [];
			var X:int = 0;
			var Y:int = 3;
			
			if (_removable)
			{
				// DeleteItemButton is a graphical item in SWC
				_deleteFormulaButton = new DeleteItemButton();
				insertTool(_deleteFormulaButton);
				_deleteFormulaButton.addEventListener(MouseEvent.CLICK, deleteFormula);
			}
			
			if (_mode == CALCULATE_MODE) 
			{
				// CalculateFormulaButton is a graphical item in SWC
				_calculateFormulaButton = new CalculateFormulaButton();
				insertTool(_calculateFormulaButton);
				_calculateFormulaButton.addEventListener(MouseEvent.CLICK, calculateFormula);
			}
			
			if (_mode == CHECK_MODE) 
			{
				// CheckFormulaButton is a graphical item in SWC
				_checkFormulaButton = new CheckFormulaButton();
				insertTool(_checkFormulaButton);
				_checkFormulaButton.addEventListener(MouseEvent.CLICK, checkFormula);
			}
			
			function insertTool(tool:SimpleButton):void
			{
				Y = listOfTools[listOfTools.length - 1] ? listOfTools[listOfTools.length - 1].y + listOfTools[listOfTools.length - 1].height + 2 : Y;
				tool.y = Y;
				tool.x = X;
				listOfTools.push(tool);
				_sidePanel.addChild(tool);
			}
		}
		
		/**
		 * This method is used to set width from parent object (formulaBox must
		 * has width not more than FormulaArea width)
		 * 
		 * @param	width
		 */
		public function setWidth(width:uint):void
		{
			_maxWidth = width;
			changeSize();
			// insert side panel
			addSidePanel();
		}
		
		/**
		 * If formula has changed we must resize the _box
		 */
		private function changeSize():void
		{
			// save the index of the _box in order to put 
			// redrawn _box on the same level
			var index:int = _formulaBox.getChildIndex(_box);
			
			_currentWidth = _maxWidth;
			if (_formula.width > _currentWidth - SIDEPANELWIDTH)
			{
				_currentWidth = _formula.width + SIDEPANELWIDTH;
				_sidePanel.x = _currentWidth - SIDEPANELWIDTH;
			}
			else
			{
				_sidePanel.x = _currentWidth - SIDEPANELWIDTH;
			}
			
			_formulaBox.removeChild(_box);
			
			var formulaBox:Shape = new Shape();
			formulaBox.graphics.beginFill(_fillColor);
			formulaBox.graphics.lineStyle(1, _borderColor);
			formulaBox.graphics.drawRect(0, 0, _currentWidth, _formula.height + 2 * PADDING);
			formulaBox.graphics.endFill();
			
			_box = formulaBox;
			
			_formulaBox.addChildAt(formulaBox, index);
		}
		
		private function deleteFormula(event:MouseEvent):void
		{
			//_formula.myParent = this;
			_formula.removeYourself();
		}
		
		public function removeYourself(deleteMe:Object = null, onlyContent:Boolean = false):void
		{
			if (deleteMe != null)
			{
				_formulaBox.removeChild(_formula);
				removeEventListener(Event.CHANGE, changed);
				_deleteFormulaButton.removeEventListener(MouseEvent.CLICK, deleteFormula);
				_calculateFormulaButton.removeEventListener(MouseEvent.CLICK, calculateFormula);
				
				_myParent.removeItem(this);
			}
		}
		
		/**
		 * Tries to calculate Formula and can do such things:
		 * 1) if the Formula is correct it puts "=XX.XX" to the right side of it
		 * 2) if the Formula is NOT correct it colored the uncorrect item 
		 * of the Formula
		 * 
		 * @param	event
		 */
		private function calculateFormula(event:MouseEvent):void
		{
			// deleting old result from right TextLeaf
			var rightTextLeaf:TextLeaf = _formula.innerItems[_formula.innerItems.length - 1];
			var oldResultPattern:RegExp = /\=–?[\d.]+/;
			var rightText:String = rightTextLeaf.innerText.text;
			rightTextLeaf.innerText.text = rightText.replace(oldResultPattern, "");
			
			// trying to calculate
			 // working with Number
			try 
			{
				var resultNumber:Array = _formula.Calculate();
			}
			catch (error:Error) 
			{
				if (error is ParserError || error is CalculationError)
				{
					(error as IElementError).instance.setFocus("left");
					NotificationWindow.show(stage, T('ErrorWindowTitle'), error.message, false);
					return;
				}
				else
					throw error;
			}
			
			if (!resultNumber)
				return;
			 // working with String
			var resultString:String = String(resultNumber[0]);
			// replace "-" (hyphen) with "--" (dash). Use Alt+0150 to put dash.
			resultString = resultString.replace("-", "–");
			
			// adding the result to the right side of Formula
			rightTextLeaf.innerText.appendText("=" + resultString);
			rightTextLeaf.update();
			
			// saying that formula has been changed
			_formula.dispatchEvent(new Event(Event.CHANGE, true));
		}
		
		private function checkFormula(event:MouseEvent):void
		{
			var correct:Boolean = false;
			var checkers:Array = _myParent.checkers;
			// use all specified checkers to validate formula	
			for (var i:int = 0; i < checkers.length; i++) 
			{
				try 
				{
					correct = checkers[i].check(_formula);
				}
				catch (error:Error) 
				{
					if (error is ParserError || error is CalculationError)
					{
						(error as IElementError).instance.setFocus("left");
						NotificationWindow.show(stage, T('ErrorWindowTitle'), error.message, false);
						return;
					}
					else
						throw error;
				}
				
				if (!correct)
					break;
			}
			// form response to the user
			if (correct)
			{ 
				NotificationWindow.show(stage, T('SuccessWindowTitle'), T('CorrectFormula'), true);
			}
			else
			{
				NotificationWindow.show(stage, T('ErrorWindowTitle'), T('IncorrectFormula'), false);
				return;
			}
		}
	}

}