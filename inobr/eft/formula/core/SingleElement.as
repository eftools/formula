package inobr.eft.formula.core 
{
	import flash.display.DisplayObject;
	import flash.events.*;
	import inobr.eft.formula.core.*;
	import inobr.eft.formula.events.*;
	import inobr.eft.formula.parser.Parser;
	
	/**
	 * ...
	 * @author gps
	 */
	public final class SingleElement extends BaseExpression
	{	
		private var _scale:Number;
		
		/**
		 * An element that can include ONLY ONE item.
		 * Use this class to create your own element.
		 * See alse MultipleElement.
		 * 
		 * @param	_parent		logical parent of item
		 * @param	scale		use Defaults to set scale
		 */
		public function SingleElement(_parent:Object, scale:Number = 1):void
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
			
			/* add new item to the list */
			_innerItems.push(leftTextLeaf);
			
			this.addChild(leftTextLeaf);
		}
		
		override public function removeYourself(deleteMe:Object = null, onlyContent:Boolean = false):void
		{
			super.removeYourself(deleteMe, onlyContent);
			
			drawMultipleElement();
		}
		
		/**
		 * Trying to calculate this block and returns it or an error.
		 * @return
		 */
		override public function getValue():Array 
		{
			var result:Array = _innerItems[0].getValue();
			
			return result;
		}
		
		/**
		 * Return needed width of element in order to seal elements.
		 * Displayed width and true width are not the same because we
		 * need to mask some parts of TextLeaf.
		 */
		override public function get width():Number 
		{
			var customWidth:int = _innerItems.length > 0 ? _innerItems[0].width : 0;
			
			return (customWidth * _scale > 0) ? customWidth * _scale : 0;
		}
		
		/**
		 * Inserts new element. New element must be an inheritor
		 * of BaseExpression class.
		 * 
		 * @param	newElement	BaseExpression
		 */
		override public function setInnerElement(newElement:BaseExpression):void 
		{
			if (_innerItems[0] is TextLeaf && 
				(_innerItems[0] as TextLeaf).innerText.text == "")
			{
				(_innerItems[0] as TextLeaf).removeYourself();
				_innerItems.pop();
				_innerItems.push(newElement);
				this.addChild(newElement as DisplayObject);
			}
			else
			{
				newElement.removeYourself();
				newElement = null;
			}
			// say about changes in Expression in order to resize all items
			dispatchEvent(new Event(Event.CHANGE, true));
		}
		
	}

}