package inobr.eft.formula.core 
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.utils.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import inobr.eft.formula.events.CalculatorEvents;
	
	
	/**
	 * A class that makes groop of specified elements on Toolbar.
	 * Category has graphical representation (categoryButton).
	 * There are more than one element in the category list.
	 * If you want to add a new Category on Toolbar (new button on Toolbar with its 
	 * pull down menu) you can do that using this class.
	 * 
	 * @author Peter Gerasimenko <gpstmp@gmail.com>
	 */
	public class Category extends Sprite 
	{
		private var _categoryItems:Array = [];
		private var _toolbarButton:SimpleButton;
		
		/**
		 * Creates an item of toolbar with given graphical representation (categoryButton)
		 * and a list of elements.
		 * 
		 * @param	categoryButton is a SimpleButton that will be presented on the toolbar
		 * @param	categoryItems is a list of Classes (from src.ru.inobr.elements) in this category
		 */
		public function Category(categoryButton:SimpleButton, categoryItems:Array):void
		{
			_toolbarButton = categoryButton;
			_categoryItems = categoryItems;
			
			addChild(drawToolbarItem());
		}
		
		/**
		 * Returns button that will represent Fractions category on the toolbar
		 * You can use library item or draw this button programmatically
		 * Recommended size of this button is 30x30
		 */
		private function drawToolbarItem():SimpleButton
		{
			var toolbarItem:SimpleButton = _toolbarButton;
			
			toolbarItem.addEventListener(MouseEvent.CLICK, toolbarItemClicked);
			
			return toolbarItem;
		}
		
		private function toolbarItemClicked(event:MouseEvent):void
		{
			dispatchEvent(new Event(CalculatorEvents.SHOW_MENU, true));
		}
		
		/**
		 * Array of elements that are in this category. Elements are from "inobr.eft.formula.elements".
		 */
		public function get categoryItems():Array
		{
			return _categoryItems;
		}
		
		/**
		 * Array of elements that are in this category. Elements are from "inobr.eft.formula.elements".
		 */
		public function set categoryItems(setValue:Array):void
		{
			if(setValue)
				_categoryItems = setValue;
		}
		
	}

}