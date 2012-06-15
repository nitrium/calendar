/**
 * EventDay
 * Single day for the calendar
 *
 * @author		Giliar Perez
 * @version		1.0.0
 */

package {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
		
	public class EventDay extends EventViewer {
	
		private var _day_object:Object; // stores object data
		private var _valid_day:Boolean; // stores if this is a valid day
		private var _this_day:int; // stores the value of this day
		private var _current:Boolean = false; // stores the status of this day (current day)
		private var _selected:Boolean = false; // stores the status of this day (current selected one)
		private var _event_type:int;
		private var _type_baseframe:int; // the base frame value depending of the type of visualization set
		private var _type1_check:Boolean = false; // stores <code>true</code> if the current day has an event type of 1 (FERIADO)
		private var _type1_val:int = 0;
	
		/**
		 * Class constructor
		 * ----------------------------------------------------------------------------------------------
		 *
		 * @param		par_x			x position
		 * @param		par_y			y position
		 * @param		par_xml		XML data of this object (day and weekday)
		 * @param		par_type	Layout type (<code>1</code> for classic; <code>2</code> for horizontal)
		 * @param		par_valid		If it is a valid day for the month (<code>true</code>/<code>false</code>)
		 * @param		par_evobj	The events for this day (in the corresponding node and in all other nodes)
		*/
		 
		public function EventDay(par_x:int, par_y:int, par_xml:XML, par_type:int, par_valid:Boolean, par_evobj:Object, par_weekdaynum:int):void {
			super(par_x, par_y, par_xml, par_type, _data_filter);
			 
			// colocar transformation for the textfields
			var _weekday_txt_format:TextFormat = new TextFormat();
			var _weeknum_txt_format:TextFormat = new TextFormat();
			 
			// sets the base frame according to the type of visualization
			if (par_type == 1) {
				week_day.visible = true;
				week_num.x = 1;
				week_num.y = 10;
				_type_baseframe = 1;
			} else if (par_type == 2) {
				week_day.visible = false;
				week_num.x = 2;
				week_num.y = 1;
				_type_baseframe = 8;
			}
			
			_event_type = par_type;
			_valid_day = par_valid;
			 
			// inserts data in the textfields
			week_num.text = par_xml.day_data.@id;
			week_day.text = par_xml.day_data.@label;
			
			// checks if this day is a valid one in the month
			if (!par_valid) {
				_weekday_txt_format.color = 0xB3A77E;
				_weeknum_txt_format.color = 0xB3A77E;
				week_day.setTextFormat(_weekday_txt_format);
				week_num.setTextFormat(_weeknum_txt_format);
				gotoAndStop(_type_baseframe + 4);
			} else {
				gotoAndStop(_type_baseframe);
			}
			
			// marks this instance as the current day (unselected)
			if ((par_xml.day_data.@id == _curr_day) && (_curr_month == _nav_month) && (_curr_year == _nav_year)) {
				// gotoAndStop(_type_baseframe + 2); ? what's the need of this?
				_current = true;
			}

			// marks the events on this day
			if (par_valid) {
				setEvents(par_evobj, par_weekdaynum);
			}
			
			//trace(par_evobj);
			//trace(par_xml);
			
			_this_day = par_xml.day_data.@id;
			_day_object = par_evobj;
			
			//trace(_this_day, " ",_day_object);
		}
		
		/**
		 * Shows the event bar according to the events on this day
		 * ----------------------------------------------------------------------------------------------
		 * The gotoAndStop values are frame labels inside the movieclip
		 * "Feriados" are never more than one day (although the current logic allows it)
		 *
		*/
		private function setEvents(par_obj:Object, par_weekendday:int):void {
			
			var _target_frame:String = "";
			
			// var _valid_weekendday:Boolean = ((par_weekendday == 6) || (par_weekendday == 0)) ? false : true;
			var _valid_weekendday:Boolean;
			var _is_holiday:Boolean = false;
			var _valid_holiday:Boolean = false;
			
			// searches to see if this day is a holiday
			if (par_obj.length > 0) {
				for (var r:int = 0; r < par_obj.length; r++) {
					if (par_obj[r].event_type == 1) {
						_is_holiday = true;
					}
				}
			}

			// just iterates if there are events in this day
			//trace(par_obj.length, " - ", par_weekendday);
			if (par_obj.length > 0) {
				for (var e:int = 0; e < par_obj.length; e++) {
					// checks for weekend days and holidays having valid events
					if (_is_holiday) { // holidays are always more important than weekend days
						if (par_obj[e].weekend_day.indexOf("FER") != -1) {
								_valid_holiday = true;
						}
						_valid_weekendday = true;
					} else {
						if (par_weekendday == 6) {
							if (par_obj[e].weekend_day.indexOf("SAB") != -1) {
								_valid_weekendday = true;
							} else {
								_valid_weekendday = false;
							}
						} else if (par_weekendday == 0)  {
							if (par_obj[e].weekend_day.indexOf("DOM") != -1) {
								_valid_weekendday = true;
							} else {
								_valid_weekendday = false;
							}
						} else {
							_valid_weekendday = true;
						}
					}
						
					if ((par_obj[e].event_type == 1) && (_data_filter != 1)) {
						if (_valid_weekendday) {
							_target_frame += "1";
						}
					}
					if ((par_obj[e].event_type == 2) && (_data_filter != 2)) {
						if (_is_holiday) {
							if (_valid_holiday && _valid_weekendday) {
								_target_frame += "3";
							}
						} else {
							if (_valid_weekendday) {
								_target_frame += "3";
							}
						}
					} 
					if ((par_obj[e].event_type == 3) && (_data_filter != 3)) {
						if (_is_holiday) {
							if (_valid_holiday && _valid_weekendday) {
								_target_frame += "2";
							}
						} else {
							if (_valid_weekendday) {
								_target_frame += "2";
							}
						}
					}
				}
			}
			//trace(week_num.text, " ", _target_frame);
			// go to the correct frame
			var _event_marker_name:MovieClip = (_event_type == 1) ? event_marker : event_marker_b;
			//trace(_target_frame);
			if ((_target_frame.indexOf("1") != -1) && (_target_frame.indexOf("2") != -1)  && (_target_frame.indexOf("3") != -1)) {
				// _event_marker_name.gotoAndStop("1_2_3");
				_event_marker_name.gotoAndStop("2_3");
				_type1_check = true;
				_type1_val = 1;
			} else if ((_target_frame.indexOf("2") != -1) && (_target_frame.indexOf("3") != -1)) {
				_event_marker_name.gotoAndStop("2_3");
			} else if ((_target_frame.indexOf("1") != -1) && (_target_frame.indexOf("3") != -1)) {
				// _event_marker_name.gotoAndStop("1_3");
				_event_marker_name.gotoAndStop("s_3");
				_type1_check = true;
				_type1_val = 1;
			 } else if ((_target_frame.indexOf("1") != -1) && (_target_frame.indexOf("2") != -1)) {
				// _event_marker_name.gotoAndStop("1_2");
				_event_marker_name.gotoAndStop("s_2");
				_type1_check = true;
				_type1_val = 1;
			 } else if (_target_frame.indexOf("1") != -1) {
				// _event_marker_name.gotoAndStop("s_1");
				_type1_check = true;
				_type1_val = 1;
			 } else if (_target_frame.indexOf("2") != -1) {
				_event_marker_name.gotoAndStop("s_2");
			 } else if (_target_frame.indexOf("3") != -1) {
				_event_marker_name.gotoAndStop("s_3");
			 }
		 }
		
		/**
		 * Returns this day and object data
		 * ----------------------------------------------------------------------------------------------
		 *
		*/
		internal function getDayVal():int {
			return _this_day;
		}
		
		internal function getDayObject():Object {
			return _day_object;
		}
		
		/**
		 * Returns the current status of this day button
		 * ----------------------------------------------------------------------------------------------
		 *
		*/
		public function getDaySelectedStatus():Boolean {
			return _selected;
		}
		
		public function getDayCurrentStatus():Boolean {
			return _current;
		}
		
		public function getValidDay():Boolean {
			return _valid_day;
		}
		
		/**
		 * Marks this day as the current selected one
		 * ----------------------------------------------------------------------------------------------
		 *
		*/
		public function setDayAsSelected(param_sel:Boolean):void {
			if (param_sel) {
				_selected_day = this.name;
				_selected = true;
				gotoAndStop(_type_baseframe + 2); // goto this day's selected frame
			} else {
				_selected = false;
				if (_current) {
					gotoAndStop(_type_baseframe + 3);
				} else {
					gotoAndStop(_type_baseframe + _type1_val);
				}
			}
		}
		
		/**
		 * Returns the current day as having events of type 1 (FERIADO)
		 * ----------------------------------------------------------------------------------------------
		 *
		*/
		public function getType1Event():Boolean {
			return _type1_check;
		}
		
		public function getType1Val():int {
			return _type1_val;
		}
		
		/**
		 * Overrides previous functions
		 * ----------------------------------------------------------------------------------------------
		 *
		*/
		override protected function populateCalendar(par_type:int, par_filter:int, par_noreset:Boolean):void {};
		override protected function setViewerData(par_xml:XML):void {};
		override protected function setNavListeners():void {};
		override protected function buildEventArrays():void {};
		
	}
	
}