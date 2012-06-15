/**
 * DropDown Item
 * Single item for the dropdown component
 *
 * @author		Giliar Perez
 * @version		1.0.0
 */

package {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public class DropDown_Item extends MovieClip {
		
		/**
		 * Parameters
		 *
		 * @param		_id				this movie id
		 */
		 private var _id:int;
		
		/**
		 * Class constructor
		 *
		 * @param		param_x				x position
		 * @param		param_y				y position
		 * @param		param_text			text for the label
		 *
		*/
		public function DropDown_Item(param_x:int, param_y:int, param_text:String, param_id:int):void {
			
			this.x = param_x;
			this.y = param_y;
			
			item_label.text = param_text;
			
			_id = param_id;
						
		}
		
		/**
		 * Getter/setter for this movie id
		 *
		*/
		public function get id():int {return _id;}
		public function set id(param_id):void {_id = param_id;}
		
		
	}
	
}