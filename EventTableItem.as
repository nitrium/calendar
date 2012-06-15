/**
 * EventTableItem
 * Single table item for the events table
 *
 * @author		Giliar Perez
 * @version		1.0.5
 
 * 19/5/2008
 * Added "ATE" as a string parameter
 */

package {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	public class EventTableItem extends MovieClip {
		
		private var _even_row_name:MovieClip;
		private var _odd_row_name:MovieClip;
		
		/**
		 * Class constructor
		 *
		*/
		public function EventTableItem(param_name:String, param_idx:int, param_y:int, param_xml:XML, param_type:int):void {
			
			var _t2_textformat:TextFormat = new TextFormat();
			_t2_textformat.size = 10;
			
			if (param_type == 1) {
				_even_row_name = tablerowbg_even;
				_odd_row_name = tablerowbg_odd;
				tablerowbg_b_even.visible = false;
				tablerowbg_b_odd.visible = false;				
				gotoAndStop("type_1");
			} else if (param_type == 2) {
				_even_row_name = tablerowbg_b_even;
				_odd_row_name = tablerowbg_b_odd;
				tablerowbg_even.visible = false;
				tablerowbg_odd.visible = false;
				gotoAndStop("type_2");
			}
			
			this.name = param_name + param_idx;
			this.y = param_y;
			
			if (param_xml != null) { // there are vents in this day
				
				// event title
				if (param_xml.link == "") {
					event_title.htmlText = param_xml.title;
				} else {
					event_title.htmlText = "<a href='" + param_xml.link + "'><font color='#004A8B'><b><u>" + param_xml.title + "</font></u></b></a>";;
				}
				
				event_title.autoSize = TextFieldAutoSize.LEFT; // event title textfield autosize
				
				var _start_date_str:String = param_xml.start_date;
				var _end_date_str:String =  param_xml.end_date;
				
				// resets start_date node if it has SAB, DOM or FER present as a string
				if (_start_date_str.indexOf("SAB") != -1) {
					var _temp_pat_a:RegExp = /SAB/;
					_start_date_str = _start_date_str.replace(_temp_pat_a, "");
				}
				if (_start_date_str.indexOf("DOM") != -1) {
					var _temp_pat_b:RegExp = /DOM/;
					_start_date_str = _start_date_str.replace(_temp_pat_b, "");
				}
				if (_start_date_str.indexOf("FER") != -1) {
					var _temp_pat_c:RegExp = /FER/;
					_start_date_str = _start_date_str.replace(_temp_pat_c, "");
				}
				
				// resets end_date node if it has SAB, DOM or FER present as a string
				if (_end_date_str.indexOf("SAB") != -1) {
					var _temp_pat1:RegExp = /SAB/;
					_end_date_str = _end_date_str.replace(_temp_pat1, "");
				}
				if (_end_date_str.indexOf("DOM") != -1) {
					var _temp_pat2:RegExp = /DOM/;
					_end_date_str = _end_date_str.replace(_temp_pat2, "");
				}
				if (_end_date_str.indexOf("FER") != -1) {
					var _temp_pat3:RegExp = /FER/;
					_end_date_str = _end_date_str.replace(_temp_pat3, "");
				}
				
				var _until_var:Boolean = false;
				if (_end_date_str.indexOf("ATE") != -1) {
					var _temp_pat4:RegExp = /ATE/;
					_end_date_str = _end_date_str.replace(_temp_pat4, "");
					_until_var = true;
				}
				
				
				// event start and end dates
				if ((_start_date_str == "") && (_end_date_str == "")) { // no event period
					event_period.htmlText = "-";
				} else if ((_start_date_str != "") && (_end_date_str == "")) { // just the start date
					if ((_start_date_str.indexOf("/") != -1) || (_start_date_str.toLowerCase() == "hoje")) { // there is a date in the xml node
						event_period.htmlText = "Hoje";
					} else if (_start_date_str.indexOf("h") != -1) { // there is a hour/minute in the xml node
						event_period.htmlText = "às " + _start_date_str;
					}
				} else if ((_start_date_str == "") && (_end_date_str != "")) { // just the end date
					event_period.htmlText = "até " + _end_date_str;
				} else if ((_start_date_str != "") && (_end_date_str != "")) { // both start and end date
					// has both dates but it is the same day
					if ((_start_date_str) == (_end_date_str)) {
						event_period.htmlText = "Hoje";
					} else if ((_start_date_str.indexOf("h") != -1) && (_end_date_str.indexOf("h") != -1)) { // there is a hour/minute in both the xml nodes
						event_period.htmlText =  _start_date_str + " " + _end_date_str;
					} else {
						if (_until_var) {
							event_period.htmlText = "até " +  _end_date_str;
						} else {
							event_period.htmlText = "de " + _start_date_str + " a " + _end_date_str;
						}
					}
				}
				
				event_period.autoSize = TextFieldAutoSize.LEFT; // event period textfield autosize
				
				// event location
				if (param_xml.location != "") {
					event_location.htmlText = param_xml.location;
				} else {
					event_location.htmlText = "-";
				}
				
				event_location.autoSize = TextFieldAutoSize.LEFT; // event period textfield autosize
				
				// type of event
				if (param_xml.type_id == "1") {
					event_type.gotoAndStop(2);
				} else if (param_xml.type_id == "2") {
					event_type.gotoAndStop(4);
				} else if (param_xml.type_id == "3") {
					event_type.gotoAndStop(3);
				}
							
				// adjusts textfields if is the second dataview type
				if (param_type == 2) {
					// sets the new size for all textfields
					event_title.setTextFormat(_t2_textformat);
					event_period.setTextFormat(_t2_textformat);
					event_location.setTextFormat(_t2_textformat);
					event_title.width = 168;
					event_period.x = 179.5;
					event_period.width = 80;
					event_location.x = 261;
					event_location.width = 89.5;
					event_type.x = 362;
					
				}
				
				// goes to correct frame to make the alternating background lines
				if (param_idx%2 == 0) {
					//gotoAndStop("even");
					_odd_row_name.visible = false;
					_even_row_name.height = this.height + 2;
				} else if (param_idx%2 == 1) {
					//gotoAndStop("odd");
					_even_row_name.visible = false;
					_odd_row_name.height = this.height + 2;
				}
				
			} else { // there are no events here
				if (param_type == 1) {
					gotoAndStop("noevent");
				} else if (param_type == 2) {
					gotoAndStop("noevent_b");
				}
			}
			
		}
		
		/**
		 * Returns this item's height
		 *
		*/
		public function getItemHeight():int {
			return this.height;
		}
		
	}
	
}