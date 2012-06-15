/**
 * EventViewer
 * Interface to view events in Calendar
 *
 * @author		Giliar Perez
 * @version		1.1.0
 * 
 * update 1.1 - 17/12/2009
 * added support for more than 12 months in a single XML
 */

package {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.display.Sprite; 
	
	public class EventViewer extends MovieClip {

		/**
		 * Parameters
		 *
		 * @param		_xml					XML container
		 * @param		_data_node				What's the node for the current month data?
		 * @param		_dataview_type			The current type of data view
		 * @param		_curr_day				Current (real) day
		 * @param		_curr_month				Current (real) month
		 * @param		_curr_year				Current (real) year
		 * @param		_nav_day				Current browsed-to day
		 * @param		_nav_month				Current browsed-to month
		 * @param		_nav_year				Current browsed-to year
		 * @param		_selected_day			Stores the current selected day
		 * @param		_weekdays_name			PT names of week days
		 * @param		_weekdays_name			PT names of week days (full form)
		 * @param		_months_name			PT names of months
		 * @param		_fulleventlist_array	Multidimensional array of all events presents in the XML file. Each index has an object with the type of event that the day has according to the XML file
		 * @param		_event_table_x			X position of event table
		 * @param		_event_table_y			Y position of event table
		 * @param		_navbt_startframe		The base frame for the nav buttons
		*/
		protected static var _xml:XML = new XML();
		protected var _data_node:int;
		protected var _dataview_type:int;
		protected static var _data_filter:int;
		protected static var _curr_day:int;
		protected static var _curr_month:int;
		protected static var _curr_year:int;
		protected static var _nav_day:int;
		protected static var _nav_month:int;
		protected static var _nav_year:int;
		protected static var _selected_day:String;
		protected var _weekdays_name:Array = new Array("D", "S", "T", "Q", "Q", "S", "S");
		protected var _weekdaysext_name:Array = new Array("Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado");
		protected var _months_name:Array = new Array("JANEIRO", "FEVEREIRO", "MARÇO", "ABRIL", "MAIO", "JUNHO", "JULHO", "AGOSTO", "SETEMBRO", "OUTUBRO", "NOVEMBRO", "DEZEMBRO");
		 
		private var _months_array:Array = new Array();
		private var _months_ctrlindex:int = -1;
		private var _fulleventlist_array:Array = new Array();
		private var _event_table_x:int;
		private var _event_table_y:int;
		 
		private var _navbt_startframe:int;
		
		/**
		 * Class constructor
		 *
		 */
		 public function EventViewer(par_x:int, par_y:int, par_xml:XML, par_type:int, par_filter:int):void {
			 
			 // object stage position
			 x = par_x;
			 y = par_y;
			 	 
			_dataview_type = par_type;
			_data_filter = par_filter;
			
			setViewerData(par_xml); // stores current XML and month data
			 
			buildEventArrays(); // builds extensive multidimensional array of days with events based on the XML
			 
			populateCalendar(_dataview_type, _data_filter, false); // inserts days
			 
			setNavListeners(); // sets button navigation
			 
		 }
		 
		 /**
		 * Sets all data
		 *
		 */
		 protected function setViewerData(par_xml:XML):void {
			 
			 _xml = par_xml; // stores xml data in local object
			 
			 _curr_day = _xml.@curr_d;
			 _curr_month = _xml.@curr_m;
			 _curr_year = _xml.@curr_y;
			 
			 _nav_day = _curr_day;
			 _nav_month = _curr_month;
			 _nav_year = _curr_year;
			 
			 // sets months in array
			 for each(var _m in _xml..month.@id) {
				 _months_array.push(_m);
			 }
			 
			 // sets view type
			 if (_dataview_type == 1) {
				 _navbt_startframe = 1;
				 gotoAndStop(_navbt_startframe);
				 cal_nav_next.x = 569.5;
				 cal_nav_next.y = 0.5;
				 cal_nav_prev.x = 0.5;
				 cal_nav_prev.y = 0.5;
				 calendar_date.visible = true;
				 calendar_date_b.visible = false;
			 } else if (_dataview_type == 2) {
				 _navbt_startframe = 5;
				 gotoAndStop(_navbt_startframe);
				 cal_nav_next.x = 156.5;
				 cal_nav_next.y = 1.5;
				 cal_nav_prev.x = 1.5;
				 cal_nav_prev.y = 1.5;
				 calendar_date.visible = false;
				 calendar_date_b.visible = true;
			 }
			 
			 // inserts table
			 if (_dataview_type == 1) {
				 _event_table_x = 5.5;
				 _event_table_y = 47;
			 } else if (_dataview_type == 2) {
				 _event_table_x = 159;
				 _event_table_y = 2;
			 }
			 var event_t:EventTable = new EventTable(_event_table_x, _event_table_y, null, _dataview_type);
			 event_t.name = "event_table";
			 addChild(event_t);
			 
		 }

		 /**
		 * Populates the event array 
		 *
		 */
		 protected function buildEventArrays():void {
			 
			// first batch - determines the year for each month
			var _monthyear_array:Array = new Array();
			var _temp_year:int = _curr_year;
			var _temp_node:int = getCurrentMonthNode(_curr_month, 0); // current month node - WARNING - it will return the first found node in the XML tree, even if there are duplicate months
			
			// builds years array
			var _xmlmonths_array:Array = new Array();
			for (var q:int = 0; q < _xml.month.length(); q++) {
				_xmlmonths_array.push(_xml.month[q].@id);
			}
			
			// DEBUGS
			
			var _break_point:int;
			for (var u:int = 0; u < _xmlmonths_array.length; u++) {
				if ((_xmlmonths_array[u] == "1") && (u != 0)) {
					_break_point = u;
				}
			}
			var _adjusted_year:int;
			if (_temp_node < _break_point) {
				_adjusted_year = _curr_year + 1;
				for (var z:int = 0; z < _xmlmonths_array.length; z++) {
					if (z < _break_point) {
						_monthyear_array.push(_curr_year);
					} else if (z >= _break_point) {
						_monthyear_array.push(_adjusted_year);
					}
				}
			} else if (_temp_node >= _break_point) {
				_adjusted_year = _curr_year - 1;
				for (var w:int = 0; w < _xmlmonths_array.length; w++) {
					if (w < _break_point) {
						_monthyear_array.push(_adjusted_year);
					} else if (w >= _break_point) {
						_monthyear_array.push(_curr_year);
					}
				}
			}
			
			// second batch - determines the quantity of days for each month
			for (var i:int = 0; i < _xml.month.length(); i++) {
				 var _month_array:Array = new Array(getMonthNumDays(_monthyear_array[i], _xml.month[i].@id)); // builds an array with the correspondent number of days
				_fulleventlist_array.push(_month_array);
				// populates each position with a new array
				for (var k:int = 0; k < _fulleventlist_array[i].length; k++) {
					var _events_array:Array = new Array();
					_fulleventlist_array[i][k] = _events_array;
				}
			}
			
			// third batch - inserts data in the full events array browsing through all xml file (all three levels)
			for (var m:int = 0; m < _xml.month.length(); m++) {
				for (var d:int = 0; d < _xml.month[m].day.length(); d++) {			
					for (var e:int = 0; e < _xml.month[m].day[d].event.length(); e++) {
						// marks all the days that have events in the full event array
						/*
						trace(_xml.month[m].day[d].event[e].start_date.indexOf("/"), " ", _xml.month[m].day[d].event[e].end_date.indexOf("/"));
						trace(_xml.month[m].day[d].event[e].start_date, " ", _xml.month[m].day[d].event[e].end_date);
						trace(m, " ", d, " ", e);
						trace("---");
						*/
						// trace(_fulleventlist_array[m][d]);
						
						/*
						if ((_xml.month[m].day[d].event[e].start_date.indexOf("/") != -1) && (_xml.month[m].day[d].event[e].end_date.indexOf("/") != -1)) { // this is a valid day to be processed, as there is start_date and end_date
							//trace(m, " ", d, " ", e);
							//trace(_xml.month[m].day[d].event[e].start_date, " ", _xml.month[m].day[d].event[e].end_date);
							buildEventsDayRange(_xml.month[m].day[d].event[e].start_date, _xml.month[m].day[d].event[e].end_date, m , d, e, _xml.month[m].day[d].event[e].type_id);
						}
						*/
						buildEventsDayRange(_xml.month[m].day[d].event[e].start_date, _xml.month[m].day[d].event[e].end_date, m , d, e, _xml.month[m].day[d].event[e].type_id);
					}
				}
			}
		 }
		 

		 /**
		 * Sets the current filter level
		 *
		 */
		 public function setEventFilter(param_idx:int):void {
			clearData(); // clears inserted month data
			 _data_filter = param_idx;
			 populateCalendar(_dataview_type, _data_filter, true);
		 }
		 
		/**
		 * Processes range data of days to mark events
		 *
		 */
		 private function buildEventsDayRange(par_st:String, par_end:String, par_m:int, par_d: int, par_e:int, par_type:int):void {
			 
			 
			// removes weekend days vars from the end
			//var _temp_var:String = "27/3 SAB DOM FER";
			var _weekend_vars:String = "";
			var _stday_string:String = par_st;
			var _endday_string:String = par_end;

			if (_endday_string.indexOf("ATE") != -1) {
				var _temp_ate:RegExp = /ATE/;
				_endday_string = _endday_string.replace(_temp_ate, "");
			}
			
			if (_endday_string.indexOf("SAB") != -1) {
				var _temp_pat1:RegExp = /SAB/;
				_endday_string = _endday_string.replace(_temp_pat1, "");
				_weekend_vars += " SAB";
			}
			if (_stday_string.indexOf("SAB") != -1) {
				var _temp_pat1b:RegExp = /SAB/;
				_stday_string = _stday_string.replace(_temp_pat1b, "");
				_weekend_vars += " SAB";
			}
			if (_endday_string.indexOf("DOM") != -1) {
				var _temp_pat2:RegExp = /DOM/;
				_endday_string = _endday_string.replace(_temp_pat2, "");
				_weekend_vars += " DOM";
			}
			if (_stday_string.indexOf("DOM") != -1) {
				var _temp_pat2b:RegExp = /DOM/;
				_stday_string = _stday_string.replace(_temp_pat2b, "");
				_weekend_vars += " DOM";
			}
			if (_endday_string.indexOf("FER") != -1) {
				var _temp_pat3:RegExp = /FER/;
				_endday_string = _endday_string.replace(_temp_pat3, "");
				_weekend_vars += " FER";
			}
			if (_stday_string.indexOf("FER") != -1) {
				var _temp_pat3b:RegExp = /FER/;
				_stday_string = _stday_string.replace(_temp_pat3b, "");
				_weekend_vars += " FER";
			}
			
			// resets end_date node with the new string without the weekend days params
			//_xml.month[par_m].day[par_d].event[par_e].end_date = _endday_string;
			
			var _start_day:int = int(par_st.substr(0, _stday_string.indexOf("/")));
			var _end_day:int = int(_endday_string.substr(0, _endday_string.indexOf("/")));
			
			// trace(par_m); // DEBUGDEBUGDEBUG
			
			var _start_node:int = getCurrentMonthNode(int(_stday_string.substr(_stday_string.indexOf("/") + 1)), par_m);
			var _end_node:int = getCurrentMonthNode(int(_endday_string.substr(_endday_string.indexOf("/") + 1)), par_m);
			
			var _day_object:Object = new Object();
			//trace(_xml.month[par_m].day[par_d].@id, ":", _start_day, "-", _end_day, "/", par_e);
			
			// no valid data range
			if ((_start_day == 0) && (_end_day == 0) || (_start_day != 0) && (_end_day == 0) || (_start_day == 0) && (_end_day != 0)) {
				//trace(_xml.month[par_m].day[par_d].@id, ":", par_m, "-", par_d, "/", par_e);

				// no valid data range
				var _day_node:int = _xml.month[par_m].day[par_d].@id - 1;
				_fulleventlist_array[par_m][_day_node].push(buildDayObject(par_m, par_d, par_e, par_type, _weekend_vars));
				
			} else if ((_xml.month[par_m].day[par_d].event[par_e].start_date.indexOf("/") != -1) && (_xml.month[par_m].day[par_d].event[par_e].end_date.indexOf("/") != -1)) { // valid data range
				
				// if it's in the same month, just insert all days in the respective array
				if (_start_node == _end_node) {
					for (var i:int = _start_day; i <= _end_day; i++) {
						var _day_events:Array = new Array(); // temporary array to store data
						// trace(_fulleventlist_array[_start_node][i].length);
						_fulleventlist_array[_start_node][i - 1].push(buildDayObject(par_m, par_d, par_e, par_type, _weekend_vars)); // inserts data in the array
					}
				} else { // the events span through two or more months
				
					// loop to populate the array when an event spans through more than two months
					for (var l:int = _start_node; l <= _end_node; l++) {
						
						// month where the events start, so it will go from the starting day to the month's end
						if (l == _start_node) {
							for (var j:int = _start_day; j <= _fulleventlist_array[_start_node].length; j++) {
								_fulleventlist_array[_start_node][j - 1].push(buildDayObject(par_m, par_d, par_e, par_type, _weekend_vars));
							}
						}
						
						// months in the middle
						if ((l != _start_node) && (l != _end_node)) {
							for (var m:int = 0; m < _fulleventlist_array[l].length; m++) {
								_fulleventlist_array[l][m].push(buildDayObject(par_m, par_d, par_e, par_type, _weekend_vars));
							}
						}
						
						// month where the events end, so it will go from first day to the final event day
						if (l == _end_node) {
							for (var k:int = 0; k < _end_day; k++) {
								_fulleventlist_array[_end_node][k].push(buildDayObject(par_m, par_d, par_e, par_type, _weekend_vars));
							}
						}
						
					}
				}
			}
			 
			// internal function to build the day object
			function buildDayObject(par_m:int, par_d:int, par_e:int, par_type:int, par_weekendday:String):Object {
				_day_object.month_node = par_m;
				_day_object.day_node = par_d;
				_day_object.event_node = par_e;
				_day_object.event_type = par_type;
				_day_object.weekend_day = par_weekendday;
				return _day_object;
			}
			 
		}
		 
		 
		/**
		 * Sets navigation buttons listeners
		 *
		 */
		 protected function setNavListeners():void {
			 
			// resets nav buttons position
			cal_nav_prev.gotoAndStop(_navbt_startframe);
			cal_nav_next.gotoAndStop(_navbt_startframe);
			 
 			cal_nav_prev.addEventListener(MouseEvent.CLICK, navPrevMonth);
 			cal_nav_prev.addEventListener(MouseEvent.MOUSE_OVER, navPrevMonth);
 			cal_nav_prev.addEventListener(MouseEvent.MOUSE_OUT, navPrevMonth);
			cal_nav_prev.buttonMode = true;
			cal_nav_next.addEventListener(MouseEvent.CLICK, navNextMonth);
			cal_nav_next.addEventListener(MouseEvent.MOUSE_OVER, navNextMonth);
			cal_nav_next.addEventListener(MouseEvent.MOUSE_OUT, navNextMonth);
			cal_nav_next.buttonMode = true;
			
			// removes actions of buttons if first or last node or both
			if (_data_node == 0) { // first node
			 	cal_nav_prev.removeEventListener(MouseEvent.CLICK, navPrevMonth);
	 			cal_nav_prev.removeEventListener(MouseEvent.MOUSE_OVER, navPrevMonth);
	 			cal_nav_prev.removeEventListener(MouseEvent.MOUSE_OUT, navPrevMonth);
				cal_nav_prev.buttonMode = false;
				cal_nav_prev.gotoAndStop(_navbt_startframe + 2);
			}
			if (_data_node == (_xml.month.length() - 1)) { // last node
				cal_nav_next.removeEventListener(MouseEvent.CLICK, navNextMonth);
				cal_nav_next.removeEventListener(MouseEvent.MOUSE_OVER, navNextMonth);
				cal_nav_next.removeEventListener(MouseEvent.MOUSE_OUT, navNextMonth);
				cal_nav_next.buttonMode = false;
				cal_nav_next.gotoAndStop(_navbt_startframe + 2);	
			}
		 }
		 
		 		 
		/**
		 * Builds day listing
		 *
		 */
		 protected function populateCalendar(par_type:int, par_filter:int, par_noreset:Boolean):void {
		 
			// _data_node = getCurrentMonthNode(_nav_month); // current month node
			 _data_node = getCurrentMonthNodeControl(_nav_month);  // current month node according to the months array
			 
			// determines current month
			calendar_date.text = _xml.month[_data_node].@label + " - " + _nav_year;
			calendar_date_b.text = _xml.month[_data_node].@label + " - " + _nav_year;;
			 
			_selected_day = ""; // blanks the selected day
			 
			// creates positioner object
			var positioner_object:MovieClip = new MovieClip();
			positioner_object.name = "pos_mc";
			addChildAt(positioner_object, 4);
			 
			var _valid_day:Boolean; // controls the valid day
			 
			var _classiccal_date:Date = new Date(_nav_year, (_nav_month - 1), 1); // calendar date
			var _classiccal_x_idx:int = _classiccal_date.getDay(); // controls the starting index of this month's calendar items
			var _classiccal_y_idx:int = 0; // indexer for vertical position
			 
			var _classiccal_xpos:int = 0; // controls each calendar item x position
			var _classiccal_ypos:int = 0; // controls each calendar item y position
			
			var _num_days:int; // total number of days this month
			if (_dataview_type == 1) {
				_num_days = 31;
			} else if (_dataview_type == 2) {
				_num_days = getMonthNumDays(_nav_year, _nav_month);
			}
			
			// loops through the calendar according to the dataview type
			if (_dataview_type == 1) {
				
				// insert all days and deactivate those which are not in the current month
				for (var i:int = 1; i <= _num_days; i++) { 
				
					var _weekday_num:int = getWeekDayNum(_nav_year, _nav_month, i);

					var _xml_data:String = "<data><day_data id=\"" + i + "\" label=\"" + getWeekDayName(_nav_year, _nav_month, i) + "\"></day_data></data>"; // builds temporary xml data
					_valid_day = (i <= getMonthNumDays(_nav_year, _nav_month)) ? true : false;
					 
					positioner_object.x = 5;
					positioner_object.y = 21;
					 
					// creates event object
					//trace(i, " ",_fulleventlist_array[_data_node][i - 1]);
					var _weekday_obj:EventDay = new EventDay((i - 1)*18, 0, XML(_xml_data), par_type, _valid_day, _fulleventlist_array[_data_node][i - 1], _weekday_num);
					_weekday_obj.name = "weekday_" + i;
					positioner_object.addChild(_weekday_obj);
					
					if (_valid_day) {
						_weekday_obj.mouseChildren = false;
						_weekday_obj.buttonMode = true;
					}
					
				}
				
			} else if (_dataview_type == 2) {
				
				positioner_object.x = 2.5;
				positioner_object.y = 37.5;
				
				var _prev_month:int = _nav_month - 1; // previous month (if 0, it's december of the previous year; if 13, it's january of the next year)
				var _prev_year:int;
				if (_prev_month == 0) {
					_prev_year = _nav_year - 1;
					_prev_month = 12;
				} else {
					_prev_year = _nav_year;
				}
				var _prev_month_qdays:int = getMonthNumDays(_prev_year, _prev_month); // quantity of days in the previous month
				var _prev_month_day:int = _prev_month_qdays - (_classiccal_x_idx - 1); // controls the last days of the previous month
				
				// first batch of days - inserts days of the previous month to the current one
				for (var m:int = 0; m <= _classiccal_x_idx; m++) {

					_classiccal_xpos = m*22;
					
					var _xml_data_inv:String = "<data><day_data id=\"" + _prev_month_day + "\" label=\"" + getWeekDayName(_prev_year, _prev_month, _prev_month_day) + "\"></day_data></data>"; // builds temporary xml data
					var _weekdayinv_obj:EventDay = new EventDay(_classiccal_xpos, _classiccal_ypos, XML(_xml_data_inv), par_type, false, null, undefined);
					_weekdayinv_obj.name = "weekdayinv_" + j;
					positioner_object.addChild(_weekdayinv_obj);
					
					_prev_month_day++;
					
				}
				
				
				// second batch - inserts all days
				for (var j:int = 1; j <= _num_days; j++) { // 35 equals to the quantity of squares in the calendar
							
					var _xml_datab:String = "<data><day_data id=\"" + j + "\" label=\"" + getWeekDayName(_nav_year, _nav_month, j) + "\"></day_data></data>"; // builds temporary xml data
					_valid_day = (j <= getMonthNumDays(_nav_year, _nav_month)) ? true : false;
					
					var _weekdayb_obj:EventDay = new EventDay(_classiccal_xpos, _classiccal_ypos, XML(_xml_datab), par_type, _valid_day, _fulleventlist_array[_data_node][j - 1], _classiccal_x_idx);
					_weekdayb_obj.name = "weekday_" + j;
					positioner_object.addChild(_weekdayb_obj);
					if (_valid_day) {
						_weekdayb_obj.mouseChildren = false;
						_weekdayb_obj.buttonMode = true;
					}
					// controls the next item position
					_classiccal_x_idx++;
					if (_classiccal_x_idx > 6) {
						_classiccal_x_idx = 0;
						_classiccal_y_idx++;
						_classiccal_ypos = _classiccal_y_idx*20;
					}
					_classiccal_xpos = _classiccal_x_idx*22;
				}
				
				// third batch - includes remaining days
				var _next_month_day:int = 1;
				var _next_month:int = _nav_month + 1; // previous month (if 0, it's december of the previous year; if 13, it's january of the next year)
				var _next_year:int;
				if (_next_month == 13) {
					_next_year = _next_year + 1;
					_next_month = 1;
				} else {
					_next_year = _nav_year;
				}
				while (_classiccal_y_idx <= 5) {
					for (var n:int = _classiccal_x_idx; n <= 6; n++) {
						
						_classiccal_xpos = _classiccal_x_idx*22;
						
						var _xml_data_nxt:String = "<data><day_data id=\"" + _next_month_day + "\" label=\"" + getWeekDayName(_next_year, _next_month, _next_month_day) + "\"></day_data></data>"; // builds temporary xml data
						var _weekdaynxt_obj:EventDay = new EventDay(_classiccal_xpos, _classiccal_ypos, XML(_xml_data_nxt), par_type, false, null, undefined);
						_weekdaynxt_obj.name = "weekdaynxt_" + n;
						positioner_object.addChild(_weekdaynxt_obj);
						
						_next_month_day++;
						_classiccal_x_idx++;
					}
					_classiccal_x_idx = 0;
					_classiccal_y_idx++;				
					_classiccal_ypos = _classiccal_y_idx*20;
				}
			}		 

			// repeats the for for each  calendar item and adds actions to all
			var _frame_eventtype:int = (par_type == 1) ? 1 : 8;
			
			for (var k:int = 1; k <= _num_days; k++) { 

				var _current_valid_day:Boolean;
			
				// this day is of the type 1 (FERIADO), so it will have a special first frame
				with (positioner_object) {
					_current_valid_day = getChildByName("weekday_" + k).getValidDay();
					if (getChildByName("weekday_" + k).getType1Event()) {
						getChildByName("weekday_" + k).gotoAndStop(_frame_eventtype + 1);
					}
				}

				// adds listener data to each day
				//if (_valid_day) {
				if (_current_valid_day) {
					positioner_object.getChildByName("weekday_" + k).addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
						//event_table.setTableData(e.target.get)
						EventTable(getChildByName("event_table")).setTableData(e.target.getDayObject(), _data_node, e.target.getDayVal(), getWeekDayExtName(e.target.getDayVal()));
						// processes click (avoids first instance since a 
						if (positioner_object.getChildByName(_selected_day) != null) {
							with (positioner_object) {
								getChildByName(_selected_day).setDayAsSelected(false);
							}
						}
						e.target.setDayAsSelected(true);
						
						_nav_day = e.target.getDayVal();
						
						// re-inserts scrollbar
						insertScrollBar();
						
					});
					positioner_object.getChildByName("weekday_" + k).addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent) :void {
						if (e.target.getDaySelectedStatus()) { // mouse out if the day was selected
							e.target.gotoAndStop(_frame_eventtype + 5);
						} else {
							e.target.gotoAndStop(_frame_eventtype + 4);
						}
					});
					positioner_object.getChildByName("weekday_" + k).addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent) :void {
						if (e.target.getDaySelectedStatus()) { // mouse out if the day was selected
							e.target.gotoAndStop(_frame_eventtype + 2);
						} else if (e.target.getDayCurrentStatus()) { // mouse out if the day was the current one
							e.target.gotoAndStop(_frame_eventtype + 3);
						} else { // mouse out in all other cases
							e.target.gotoAndStop(_frame_eventtype + e.target.getType1Val()); 
						}
						
					});
				}
				
			 }
			 
			// marks the current day (if it is the current day/month/year) or the first day on a different month
			var _day_object:Object;
			var _day_val:int;
			var _weekdayext_name:String;
			var _current_day_autoselect:int;
			// the table reset comes though the filter dropdown, so it must go to the previously selected day
			if (par_noreset) {
				_current_day_autoselect = _nav_day;
			} else if ((_curr_month == _nav_month) && (_curr_year == _nav_year)) {
				_current_day_autoselect = _curr_day;
			} else { // marks the first day of the month as the selected one
				_current_day_autoselect = 1;
			}
			with (positioner_object) {
				_day_object = getChildByName("weekday_" + _current_day_autoselect).getDayObject();
				_day_val = getChildByName("weekday_" + _current_day_autoselect).getDayVal();
				_weekdayext_name = getWeekDayExtName(_day_val);
				getChildByName("weekday_" + _current_day_autoselect).setDayAsSelected(true);
			}
			// resets position of event table
			EventTable(getChildByName("event_table")).setTableData(_day_object, _data_node, _day_val, _weekdayext_name);
		
			// adds mask and scrollbar content depending on the dataview type
			
			var mask_obj:Sprite = new Sprite();
			mask_obj.name = "mask_mc";
			
			mask_obj.graphics.beginFill(0x00CC00);
			if (_dataview_type == 1) {
				mask_obj.graphics.drawRect(5.5, 47, 540, 129);
			} else if (_dataview_type == 2) {
				mask_obj.graphics.drawRect(158, 1.5, 392, 177);
			}
			
			addChildAt(mask_obj, 6);
			getChildByName("event_table").mask = mask_obj;
			
			// inserts scrollbar
			insertScrollBar();			
			 
		 }
		 
		 /**
		 * Handles nav buttons actions
		 *
		 */
		 private function navNextMonth(e:MouseEvent):void { // next month
			 switch (e.type) {
				 case "click":
				 	setNewMonth(++_data_node, "next"); 
				 	break;
				 case "mouseOut":
				 	e.target.gotoAndStop(_navbt_startframe);
				 	break;
				 case "mouseOver":
				 	e.target.gotoAndStop(_navbt_startframe + 1);
				 	break;
			 }
		 }
		 private function navPrevMonth(e:MouseEvent):void { // previous month
		 	switch (e.type) {
				 case "click":
				 	setNewMonth(--_data_node, "prev");
				 	break;
				 case "mouseOut":
				 	e.target.gotoAndStop(_navbt_startframe);
				 	break;
				 case "mouseOver":
				 	e.target.gotoAndStop(_navbt_startframe + 1);
				 	break;
			 }
		 }
		 
		/**
		 * Determines quantity of days in current month
		 *
		 */
		 private function getMonthNumDays(par_navy:int, par_navm:int):int {
			 var _date:Date = new Date(par_navy, par_navm, 0);
			 return _date.getDate();
		 }
		
		/**
		 * Navigates through the XML structure of months
		 *
		 */
		 private function setNewMonth(par_idx:int, par_dir:String):void {

			clearData(); // clears inserted month data
			
			_nav_day = 1; // sets the first day being 1 since it is not the current month
			_nav_month = _xml.month[par_idx].@id;
			
			//trace(_xml.month[_xml.month.length()-1].@id);
			//trace(_nav_month);
			
			// determines the year
			if (par_dir == "next") {
				if ((_nav_month == 1) && (_xml.month[par_idx - 1].@id == 12)) {
					++_nav_year;
				}
			} else if (par_dir == "prev") {
				if ((_nav_month == 12) && (_xml.month[par_idx + 1].@id == 1)) {
					--_nav_year;
				}
			}
			
			/*if ((_nav_month == 1) && (_xml.month[par_idx - 1].@id == 12) && (par_dir == "next")) { // this is a "january" in the middle of the XML, the previous node was december and the user is forwarding the list
				_nav_year++;
			} else if ((_nav_month == 12) && (_xml.month[_xml.month.length()-1].@id != 12) && (_xml.month[par_idx + 1].@id == 1) && (par_dir == "prev")) { // this is a "December" in the middle of the XML, the next node was january and the user is rewinding the list
				_nav_year--;
			}*/
			
			//trace(_nav_year);
			setNavListeners(); // resets button navigation
			
			populateCalendar(_dataview_type, _data_filter, false); // inserts days
			
		 }
		
		/**
		 * Check if it is a leap year
		 *
		 */
		private function isLeapYear(date:Date):Boolean {
			var _ynum = date.getFullYear();
			return ((_ynum%4 == 0) && (_ynum%100 == 0 ? (_ynum%400 == 0) : true));
		}
		

		/**
		 * Determines current week day name
		 *
		 */
		 private function getWeekDayName(par_navy:int, par_navm:int, par_day:int):String {
			 var _date:Date = new Date(par_navy, (par_navm - 1), par_day);
			 return _weekdays_name[_date.getDay()];
		 }
		 
		 private function getWeekDayExtName(par_idx:int):String {
			 var _date:Date = new Date(_nav_year, (_nav_month - 1), par_idx);
			 return _weekdaysext_name[_date.getDay()];
		 }
		 
		 protected function getWeekDayNum(par_navy:int, par_navm:int, par_day:int):int {
			 var _date:Date = new Date(par_navy, (par_navm - 1), par_day);
			 return _date.getDay();
		 }
		 
		/**
		* Returns the current month node
		*
		*/
		private function getCurrentMonthNode(par_idx:int, par_st:int):int { // par_st is the start node in the xml file to start looking for the month
			
			//trace(par_idx);
			var _current_node:int;
			
			for (var i:int = par_st; i < _xml.month.length(); i++) {
				if (_xml.month[i].@id == par_idx) {
					_current_node = i;
					break;
				}
			}
			
			return _current_node;
		}
		
		/**
		* Returns the current month node (acording to the updated array, not the XML data
		*
		*/
		private function getCurrentMonthNodeControl(par_idx:uint):uint {
			
			_months_ctrlindex = (_months_ctrlindex == -1) ? getCurrentMonthNode(par_idx, 0) : _months_ctrlindex; // if it wasn't previously defined, define it now
			/*
			trace(_months_ctrlindex);
			trace(_months_array[_months_ctrlindex + 1], " / ", par_idx);
			*/
			// detects which direction the navigation is going
			if (_months_array[_months_ctrlindex + 1] == par_idx) {
				++_months_ctrlindex;
			} else if (_months_array[_months_ctrlindex - 1] == par_idx) {
				--_months_ctrlindex;
			}
			/*
			for (var _f:uint = _months_ctrlindex + 1; _f < _months_array.length; _f++) {
				trace(_months_array[_f]);
			}
			
			trace("---------------");
			trace(_months_ctrlindex);
			*/
			return _months_ctrlindex;
			
		}
		
		/**
		* Returns the current day node
		 * This function should return an "int", but when a day is not present in the XML file and the return type is "int", it returns a
		 * "0", which gets confusing since the first node is also "0", so it must return a "String" so when the current day is not present
		 * in the XML file, it returns a "null" value
		*
		*/
		protected function getCurrentDayNode(par_idx:int):String {
			
			var _current_node:String;
			for (var a:int = 0; a < _xml.month[_data_node].day.length(); a++) {
				if (_xml.month[_data_node].day[a].@id == par_idx) {
					_current_node = a.toString();
					break;
				}

			}
			return _current_node;
		}
		
		/**
		 * Inserts or re-inserts the scrollbar
		 *
		 */
		 private function insertScrollBar():void {

			// removes scrollbar if it exists
			if (getChildByName("scrollbar") != null) {
				removeChild(getChildAt(7));
			}

			// resets table position
			getChildByName("event_table").y = _event_table_y;
			
			// adds scrollbar
			
			var _scroll_xpos:int = (_dataview_type == 1) ? 540.5 : 544.5;
			var _scroll_ypos:int = (_dataview_type == 1) ? 47.5 : 1.5;
			
			var scrollbar:Scrollbar = new Scrollbar(_scroll_xpos, _scroll_ypos);
			scrollbar.name = "scrollbar";
			addChildAt(scrollbar,7);
			if (_dataview_type == 2) {
				scrollbar.adjustHeight(177);
			}
			scrollbar.initializeScroll("event_table", "mask_mc");
			
		 }
		 
		/**
		* Clear internal data
		*
		*/
		private function clearData():void {			
		
			removeChild(getChildAt(6)); // removes previously inserted mask
		
			removeChild(getChildAt(4)); // removes data table
			
		}
		
	}
}