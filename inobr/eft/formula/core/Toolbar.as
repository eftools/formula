package inobr.eft.formula.core 
{
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.*;
	
	import inobr.eft.formula.elements.functions.*;
	import inobr.eft.formula.elements.main.*;
	import inobr.eft.formula.events.CalculatorEvents;
	import inobr.eft.common.ui.*;
		
	/**
	 * ...
	 * @author Peter Gerasimenko (gpstmp@gmail.com)
	 */
	public class Toolbar extends Sprite 
	{
		// list of elements that must be in the toolbar
		private var _toolbarItemsList:Array = [];
		
		private var _toolbarItems:Array = [];
		private var format:BlockFormat;
		
		private var _toolbar:Sprite = new Sprite();
		private var toolbarBack:Shape;
		
		private var pullDownMenu:GScrollPane/*Sprite*/;
		private var pullDownItems:Array = [];
		private var menuHeight:uint = 120;
		private var menuWidth:uint = 141;//135;
		
		private var currentCategory:Sprite = null;
		
		/**
		 * Create a Toolbar for FormulaWorkspace.
		 * You can set format of its rectangle.
		 * 
		 * @param	height
		 * @param	format
		 */	
		public function Toolbar(height:uint, format:BlockFormat):void 
		{
			this.format = format;
			addChild(_toolbar);
			drawToolbar(150, height);
			drawPullDownMenu(menuWidth, menuHeight);
			addEventListener(CalculatorEvents.SHOW_MENU, showPullDownMenu);
		}
		
		private function drawToolbar(width:uint, height:uint):void
		{
			try 
			{
				var depth:int = _toolbar.getChildIndex(toolbarBack);
				_toolbar.removeChild(toolbarBack);
			}
			catch (error:Error) { }
			// add items in toolbar according to the _toolbarItems
			toolbarBack = new Shape();
			toolbarBack.graphics.beginFill(format.blockFill);
			toolbarBack.graphics.lineStyle(format.borderWidth, format.borderColor);
			toolbarBack.graphics.drawRect(0, 0, width, height);
			toolbarBack.graphics.endFill();
			
			_toolbar.addChildAt(toolbarBack, depth);
		}
		
		private function drawPullDownMenu(width:uint, height:uint):void
		{
			pullDownMenu = new GScrollPane(width + 11,
										   height,
										   format);
			
			addChild(pullDownMenu);
			pullDownMenu.visible = false;
		}
		
		private function fillToolbar():void
		{
			var tools:Array = [];
			
			// create all the toolbar items
			for (var i:int = 0; i < _toolbarItemsList.length; i++) 
			{
				tools.push(_toolbarItemsList[i]);
			}
			
			// place all the toolbar items
			tools[0].x = format.marginHorizontal / 2;
			tools[0].y = _toolbar.height / 2 - tools[0].height / 2;
			_toolbar.addChild(tools[0]);
			
			var newY:uint = tools[0].y;
			var numberOfLines:uint = 0;
			
			for (i = 1; i < tools.length; i++) 
			{
				var newX:uint = tools[i - 1].x + tools[i - 1].width + format.marginHorizontal / 2;
				
				if (newX + tools[i].width + format.marginHorizontal / 2 > _toolbar.width)
				{
					numberOfLines++;
					newX = tools[0].x;
					newY = tools[0].y + tools[0].height + format.marginVertical / 2;
				}
				tools[i].x = newX;
				tools[i].y = newY;
				
				_toolbar.addChild(tools[i]);
			}
			
			_toolbarItems = tools;
		}
		
		private function showPullDownMenu(event:Event):void
		{
			var newX:int = 0;
			var newY:int = 0;
			for (var i:int = 0; i < _toolbarItems.length; i++) 
			{
				if (_toolbarItems[i] == event.target)
				{
					newX = _toolbarItems[i].x;
					newY = Math.floor(_toolbarItems[i]. y + _toolbarItems[i].height + format.marginVertical);
					break;
				}
			}
			
			fillPullDownMenu(i);
			
			if(currentCategory == event.target)
				pullDownMenu.visible ? pullDownMenu.visible = false : pullDownMenu.visible = true;
			else
				pullDownMenu.visible = true;
				
			pullDownMenu.x = newX;
			pullDownMenu.y = newY;
			currentCategory = (event.target as Sprite);
		}
		
		private function fillPullDownMenu(category:int):void
		{
			var categoryItems:Array = _toolbarItems[category].categoryItems;
			
			for (var i:int = 0; i < pullDownItems.length; i++) 
			{
				pullDownMenu.content.removeChild(pullDownItems[i]);
			}
			pullDownItems.splice(0, pullDownItems.length - 1);
			
			if (pullDownMenu.content)
			{
				// after selecting any item we hide pullDownMenu
				pullDownMenu.content.removeEventListener(MouseEvent.CLICK, clickOnMenuItem);
				pullDownMenu.removeChild(pullDownMenu.content);
			}
			
			for (i = 0; i < categoryItems.length; i++) 
			{
				if (categoryItems[i] is Class)
				{
					var ClassReference:Class = categoryItems[i] as Class;
					pullDownItems[i] = ClassReference['getToolbarItem']();
				}
				else
				{
					pullDownItems[i] = categoryItems[i];
				}
				
				//pullDownItems[i] = ClassReference['getToolbarItem']();
			}
			
			formPullDownMenu();
		}
		
		private function formPullDownMenu():void
		{
			var numberOfColumns:uint = 3;
			var numberOfLines:uint = 0;
			var content:Sprite = new Sprite();
			
			numberOfLines = Math.floor(pullDownItems.length / numberOfColumns);
			
			pullDownItems[0].x = 0;
			pullDownItems[0].y = 0;
			content.addChild(pullDownItems[0]);
			
			var newY:uint = pullDownItems[0].y;
			
			var currentLine:uint = 1;
			
			for (var i:int = 1; i < pullDownItems.length; i++) 
			{
				var newX:uint = pullDownItems[i - 1].x + pullDownItems[i - 1].width + format.marginHorizontal;
				
				if (i > currentLine * numberOfColumns - 1)
				{
					newX = pullDownItems[0].x;
					newY = pullDownItems[i - 1].y + 
						   pullDownItems[i - 1].height + format.marginVertical;
						   
					currentLine++;
				}
				
				pullDownItems[i].x = newX;
				pullDownItems[i].y = newY;
				
				content.addChild(pullDownItems[i]);
			}
			
			var index:int = getChildIndex(pullDownMenu);
				removeChildAt(index);
			var visibility:Boolean = pullDownMenu.visible;
			
			if (pullDownItems[pullDownItems.length - 1].y < menuHeight)
			{	
				var newHeight:uint = pullDownItems[pullDownItems.length - 1].y + 
									 pullDownItems[pullDownItems.length - 1].height + 
									 2 * format.marginVertical + format.borderWidth;
					
				pullDownMenu = new GScrollPane(menuWidth,
											   newHeight,
											   format);
			}
			else
			{
				pullDownMenu = new GScrollPane(menuWidth + 11,
											   menuHeight,
											   format);
			}
			
			pullDownMenu.content = content;
			pullDownMenu.updateScroll();
			addChildAt(pullDownMenu, index);
			
			pullDownMenu.visible = visibility;
			// after selecting any item we hide pullDownMenu
			content.addEventListener(MouseEvent.CLICK, clickOnMenuItem);
		}
		
		private function clickOnMenuItem(event:MouseEvent):void
		{
			if (pullDownMenu.visible)
				pullDownMenu.visible = false;
		}
		
		/**
		 * Redrawing toolbar with specified width and height.
		 * 
		 * @param	width
		 * @param	height
		 */
		public function resizeToolbar(width:uint, height:uint):void
		{	
			drawToolbar(width - format.borderWidth, height - format.borderWidth);
		}
		
		/**
		 * Adds new category to the toolbar. Any category
		 * contains a list of its elements.
		 * 
		 * @param	category	exemplar of Category class
		 */
		public function addCategory(category:Category):void
		{
			_toolbarItemsList.push(category);
			fillToolbar();
		}
		
		/**
		 * Creates an item of toolbar with given graphical representation (categoryButton)
		 * and a list of elements.
		 * @param	categoryButton is a SimpleButton that will be presented on the toolbar
		 * @param	categoryItems is a list of Classes (from src.ru.inobr.elements) in this category
		 */
		public function addCategoryByParams(categoryButton:SimpleButton, categoryItems:Array):void
		{
			addCategory(new Category(categoryButton, categoryItems));
		}
		
		// getters and setters
		
		// because there is a pullDownMenu that has big height and is not a toolbar
		override public function get height():Number 
		{
			// add borderWidth because it is not included in height of rectangle
			return _toolbar.height + format.borderWidth;
		}
		
		override public function set height(value:Number):void 
		{
			super.height = value;
		}
	}

}