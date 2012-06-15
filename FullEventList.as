package {
	
	public class FullEventList {
		
		private static var _curr_day:int;
		private static var _curr_month:int;
		private static var _curr_year:int;
		private static var _nav_day:int;
		private static var _nav_month:int;
		private static var _nav_year:int;
		private static var _selected_day:String;
		
		private static var xml_data:XML = new XML();
		private var fulleventlist_array:Array = new Array();
		
		/**
		* Class constructor
		*
		*/
		public function FullEventList(_xml:XML):void {
			
			xml_data = _xml;
			
			buildEventArrays();
			
			// *** DEBUG ***
			/*
			for (var i:int = 0; i < fulleventlist_array.length; i++) {
				trace("Month id: " + xml_data.month[i].@id);
				trace("*************************");
				for (var j:int = 0; j < fulleventlist_array[i].length; j++) {
					trace("Day id: " + (j+1) + " -------------------------------");
					for (var k:int = 0; k < fulleventlist_array[i][j].length; k++) {
						trace(fulleventlist_array[i][j][k]);
						trace("month_node: " + fulleventlist_array[i][j][k].month_node);
						trace("day_node: " + fulleventlist_array[i][j][k].day_node)
						trace("event_node: " + fulleventlist_array[i][j][k].event_node)
						trace("event_type: " + fulleventlist_array[i][j][k].event_type)
						trace("weekend_day: " + fulleventlist_array[i][j][k].weekend_day)
					}
					trace("//////////////");
				}
				trace("=/======================/=");
			}
			*/
		}
		
		/**
		* Populates the event array 
		*
		*/
		private function buildEventArrays():void {
			 
			// first batch - determines the year for each month
			var _monthyear_array:Array = new Array();
			var _temp_year:int = _curr_year;
			var _temp_node:int = getCurrentMonthNode(_curr_month); // current month node
			
			// builds years array
			var xml_datamonths_array:Array = new Array();
			for (var q:int = 0; q < xml_data.month.length(); q++) {
				xml_datamonths_array.push(xml_data.month[q].@id);
			}
			var _break_point:int;
			for (var u:int = 0; u < xml_datamonths_array.length; u++) {
				if ((xml_datamonths_array[u] == "1") && (u != 0)) {
					_break_point = u;
				}
			}
			var _adjusted_year:int;
			if (_temp_node < _break_point) {
				_adjusted_year = _curr_year + 1;
				for (var z:int = 0; z < xml_datamonths_array.length; z++) {
					if (z < _break_point) {
						_monthyear_array.push(_curr_year);
					} else if (z >= _break_point) {
						_monthyear_array.push(_adjusted_year);
					}
				}
			} else if (_temp_node >= _break_point) {
				_adjusted_year = _curr_year - 1;
				for (var w:int = 0; w < xml_datamonths_array.length; w++) {
					if (w < _break_point) {
						_monthyear_array.push(_adjusted_year);
					} else if (w >= _break_point) {
						_monthyear_array.push(_curr_year);
					}
				}
			}
			
			// second batch - determines the quantity of days for each month
			for (var i:int = 0; i < xml_data.month.length(); i++) {
				 var _month_array:Array = new Array(getMonthNumDays(_monthyear_array[i], xml_data.month[i].@id)); // builds an array with the correspondent number of days
				fulleventlist_array.push(_month_array);
				// populates each position with a new array
				for (var k:int = 0; k < fulleventlist_array[i].length; k++) {
					var _events_array:Array = new Array();
					fulleventlist_array[i][k] = _events_array;
				}
			}
			
			// third batch - inserts data in the full events array browsing through all xml file (all three levels)
			for (var m:int = 0; m < xml_data.month.length(); m++) {
				for (var d:int = 0; d < xml_data.month[m].day.length(); d++) {			
					for (var e:int = 0; e < xml_data.month[m].day[d].event.length(); e++) {
						// marks all the days that have events in the full event array
						/*
						trace(xml_data.month[m].day[d].event[e].start_date.indexOf("/"), " ", xml_data.month[m].day[d].event[e].end_date.indexOf("/"));
						trace(xml_data.month[m].day[d].event[e].start_date, " ", xml_data.month[m].day[d].event[e].end_date);
						trace(m, " ", d, " ", e);
						trace("---");
						*/
						// trace(fulleventlist_array[m][d]);
						
						/*
						if ((xml_data.month[m].day[d].event[e].start_date.indexOf("/") != -1) && (xml_data.month[m].day[d].event[e].end_date.indexOf("/") != -1)) { // this is a valid day to be processed, as there is start_date and end_date
							//trace(m, " ", d, " ", e);
							//trace(xml_data.month[m].day[d].event[e].start_date, " ", xml_data.month[m].day[d].event[e].end_date);
							buildEventsDayRange(xml_data.month[m].day[d].event[e].start_date, xml_data.month[m].day[d].event[e].end_date, m , d, e, xml_data.month[m].day[d].event[e].type_id);
						}
						*/
						buildEventsDayRange(xml_data.month[m].day[d].event[e].start_date, xml_data.month[m].day[d].event[e].end_date, m , d, e, xml_data.month[m].day[d].event[e].type_id);
					}
				}
			}
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
			//xml_data.month[par_m].day[par_d].event[par_e].end_date = _endday_string;
			
			var _start_day:int = int(par_st.substr(0, _stday_string.indexOf("/")));
			var _end_day:int = int(_endday_string.substr(0, _endday_string.indexOf("/")));
			var _start_node:int = getCurrentMonthNode(int(_stday_string.substr(_stday_string.indexOf("/") + 1)));
			var _end_node:int = getCurrentMonthNode(int(_endday_string.substr(_endday_string.indexOf("/") + 1)));
			var _day_object:Object = new Object();
			//trace(xml_data.month[par_m].day[par_d].@id, ":", _start_day, "-", _end_day, "/", par_e);
			
			// no valid data range
			if ((_start_day == 0) && (_end_day == 0) || (_start_day != 0) && (_end_day == 0) || (_start_day == 0) && (_end_day != 0)) {
				//trace(xml_data.month[par_m].day[par_d].@id, ":", par_m, "-", par_d, "/", par_e);

				// no valid data range
				var _day_node:int = xml_data.month[par_m].day[par_d].@id - 1;
				fulleventlist_array[par_m][_day_node].push(buildDayObject(par_m, par_d, par_e, par_type, _weekend_vars));
				
			} else if ((xml_data.month[par_m].day[par_d].event[par_e].start_date.indexOf("/") != -1) && (xml_data.month[par_m].day[par_d].event[par_e].end_date.indexOf("/") != -1)) { // valid data range
				
				// if it's in the same month, just insert all days in the respective array
				if (_start_node == _end_node) {
					for (var i:int = _start_day; i <= _end_day; i++) {
						var _day_events:Array = new Array(); // temporary array to store data
						// trace(fulleventlist_array[_start_node][i].length);
						fulleventlist_array[_start_node][i - 1].push(buildDayObject(par_m, par_d, par_e, par_type, _weekend_vars)); // inserts data in the array
					}
				} else { // the events span through two or more months
				
					// loop to populate the array when an event spans through more than two months
					for (var l:int = _start_node; l <= _end_node; l++) {
						
						// month where the events start, so it will go from the starting day to the month's end
						if (l == _start_node) {
							for (var j:int = _start_day; j <= fulleventlist_array[_start_node].length; j++) {
								fulleventlist_array[_start_node][j - 1].push(buildDayObject(par_m, par_d, par_e, par_type, _weekend_vars));
							}
						}
						
						// months in the middle
						if ((l != _start_node) && (l != _end_node)) {
							for (var m:int = 0; m < fulleventlist_array[l].length; m++) {
								fulleventlist_array[l][m].push(buildDayObject(par_m, par_d, par_e, par_type, _weekend_vars));
							}
						}
						
						// month where the events end, so it will go from first day to the final event day
						if (l == _end_node) {
							for (var k:int = 0; k < _end_day; k++) {
								fulleventlist_array[_end_node][k].push(buildDayObject(par_m, par_d, par_e, par_type, _weekend_vars));
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
		* Returns the current month node
		*
		*/
		private function getCurrentMonthNode(par_idx:int):int {
			var _current_node:int;
			for (var i:int = 0; i < xml_data.month.length(); i++) {
				if (xml_data.month[i].@id == par_idx) {
					_current_node = i;
					break;
				}
			}
			return _current_node;
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
		* Returns the current month array
		*
		*/
		public function getMonthDayData(_p_month:int):Object {
			return fulleventlist_array[_p_month];
		}
		
	}
}