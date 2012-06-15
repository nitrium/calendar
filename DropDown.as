/**
 * DropDown
 * Base class for the dropdown component
 *
 * @author		Giliar Perez
 * @version		1.0.0
 */

package {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import fl.transitions.easing.*;
	import fl.transitions.Tween;
	
	public class DropDown extends MovieClip {
		
		/**
		 * Parameters
		 * ----------------------------------------------------------------------------------------------
		 *
		 * @param		_item_list				Stores the dropdown items
		 * @param		_return_function		Name of return function when user clicks a dropdown item
		 * @param		_last_clicked			Last dropdown item clicked
		 * @param		item_positioner		Container for dropdown list items
		 * @param		_ITEM_YINC			The vertical increase value of each item on the dropdown list
		 * @param		_item_list_ypos		The closed y position of the item list
		 * @param		_dropstatus_open	Status of the dropdown
		*/
		private var _item_list:Array;
		private var _return_function:String;
		private var _last_clicked:int;
		private var item_list:MovieClip = new MovieClip();
		
		private var _ITEM_YINC:int = 18;
		
		private var _itempositioner_closedypos:int;
		private var _dropstatus_open:Boolean = false;
		
		/**
		 * Class constructor
		 *
		 * @param		param_x				x position
		 * @param		param_y				y position
		 * @param		param_items		the dropdown items
		 * @param		param_retfunc	the return function when a button is clicked
		 *
		*/
		public function DropDown(param_x:int, param_y:int, param_items:Array, param_retfunc:String):void {
			
			this.x = param_x;
			this.y = param_y;
			
			_item_list = param_items;
			_return_function = param_retfunc;
			
			// initial population of dropdown
			main_label.text = _item_list[0];
			
			// defines the last clicked item as the first one in the list (default value);
			_last_clicked = 0;
			
			// positioner for the dropdown list items
			item_positioner.addChild(item_list);
			
			// calls functions to define the list of dropdown items
			setDropDownList();
			
			// adds mask
			var mask_obj:Sprite = new Sprite();
			mask_obj.name = "mask_mc";
			mask_obj.graphics.beginFill(0x00CC00);
			mask_obj.graphics.drawRect(0, 10, 207, 150);
			addChild(mask_obj);
			item_positioner.mask = mask_obj;
			
			// defines main button actions
			dropdown_hitbt.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
				dropdown_bt.gotoAndStop(3);
			});
			dropdown_hitbt.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
				dropdown_bt.gotoAndStop(1);
			});
			dropdown_hitbt.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				dropdown_bt.gotoAndStop(1);
				if (!_dropstatus_open) {
					openDropDownList();
				} else {
					closeDropDownList();
				}
			});
			dropdown_hitbt.buttonMode = true;
			
			// repositions the item positioner
			_itempositioner_closedypos = (0 - item_positioner.height) + 26;
			item_positioner.y = _itempositioner_closedypos;
			
		}
		
		/**
		 * Sets the list of dropdown items
		 *
		*/
		private function setDropDownList():void {
			
			// removes previously entered content in the dropdown list
			
			
			// adds other items
			var _y_inc_pos:int = 0;
			
			for (var i:int = 0; i < _item_list.length; i++) {
				if (_last_clicked != i) {
					var _dropdown_item:DropDown_Item = new DropDown_Item(0, _y_inc_pos, _item_list[i], i);
					
					// listeners
					_dropdown_item.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
						e.target.gotoAndStop(3);
					});
					_dropdown_item.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
						e.target.gotoAndStop(1);
					});
					_dropdown_item.addEventListener(MouseEvent.CLICK, itemClick);
					_dropdown_item.mouseChildren = false;
					_dropdown_item.buttonMode = true;
					
					// adds item
					with (item_positioner) {
						item_list.addChild(_dropdown_item);
					}
					_y_inc_pos += _ITEM_YINC;
				}
			}
			
			// sets the background height
			item_positioner.dropdown_bg.height = (_ITEM_YINC*(_item_list.length)) + 2;
			
		}
		
		/**
		 * Handles the dropdown list opening
		 *
		*/
		private function openDropDownList():void {
			_dropstatus_open = true;
			drop_bt.gotoAndStop(3);
			var open_tween:Tween = new Tween(item_positioner, "y", Regular.easeOut, item_positioner.y, 21, 0.3, true);
			stage.addEventListener(MouseEvent.CLICK, mouseRelease);
		}
		
		/**
		 * Handles the dropdown list closing
		 *
		*/
		private function closeDropDownList():void {
			_dropstatus_open = false;
			drop_bt.gotoAndStop(1);
			var open_tween:Tween = new Tween(item_positioner, "y", Regular.easeIn, item_positioner.y, _itempositioner_closedypos, 0.3, true);
		}
		
		/**
		 * Handles mouserelease outsite the area
		 *
		*/
		private function mouseRelease(e:MouseEvent):void {
			if (e.target != dropdown_hitbt) {
				closeDropDownList();
				stage.removeEventListener(MouseEvent.CLICK, mouseRelease);			
			}
		}
		
		/**
		 * Processes a click in a dropdown list item
		 *
		*/
		private function itemClick(e:MouseEvent):void {
			_last_clicked = e.target.id;
			main_label.text = _item_list[e.target.id];
			setDropDownList();
			Calendar(parent)[_return_function] = e.target.id;
		}
		
	}
	
}