/**
 * EventTable
 * Table of events for a specific day
 *
 * @author		Giliar Perez
 * @version		1.0.0
 */

package {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public class EventTable extends EventViewer {
		
		/**
		 * Parameters
		 * ----------------------------------------------------------------------------------------------
		 *
		 * @param		_data_check		Stores <code>true</code> if there is any data in this day or <code>false</false> if there's no data (empty events day)
		 * @param		_table_h			Stores the total table height		
		 */
		 private var _data_check:Boolean;
		 private var _table_h:int;
		
		/**
		 * Class constructor
		 * ----------------------------------------------------------------------------------------------
		 *
		 * @param		par_x			x position
		 * @param		par_y			y position
		 * @param		par_xml		null data
		 * @param		par_type	the type of table
		*/
		public function EventTable(par_x:int, par_y:int, par_xml:XML, par_type:int):void {
			super(par_x, par_y, par_xml, par_type, _data_filter);
			
			this.x = par_x;
			this.y = par_y;
			
			// adds table positioner

		}
		
		/**
		 * Buils table with input data
		 * ----------------------------------------------------------------------------------------------
		 *
		 * @param		par_obj			object with nodes reference
		 * @param		par_mnode		the corresponding month node
		 * @param		par_day			the corresponding day (may be in the XML or not)
		 * @param		par_dayname	the name of the day (string)
		*/
		public function setTableData(par_obj:Object, par_mnode:int, par_day:int, par_dayname:String):void { 
			
			// sets the content according to the dataview type
			if (_dataview_type == 1) {
				gotoAndStop(1);
			} else if (_dataview_type == 2) {
				gotoAndStop(9);
			}			
			
			current_day.text = par_dayname + ", " + par_day + " de " + _months_name[_xml.month[par_mnode].@id - 1].toLowerCase() + " de " + _nav_year; // sets date
			
			_data_node = par_mnode; // local var
			
			_data_check = false; // sets the day as being empty of events

			// clears preloaded data
			if (getChildByName("table_positioner") != null) {
				removeChildAt(12);
			}
			// adds table positioner
			var _table_positioner:MovieClip = new MovieClip();
			_table_positioner.name = "table_positioner";
			addChildAt(_table_positioner, 12);
			_table_positioner.x = 2;
			_table_positioner.y = 35.5;
			
			// table row position (the y value gets increased as more rows are added)
			var _tablerow_y:int = 0;
			
			var _tablerow_idx:int = 0; // indexer for table row to check if it is even or odd (can't use the iterator in the "for" because it breaks the even/odd row)
			
			var _real_events_qnt:int = _xml.month[par_mnode].day[getCurrentDayNode(par_day)].event.length(); // the quantity of "real" (listed in the xml) events for this day
			
			// checks if this is a FERIADO type event
			var _is_holiday:Boolean = false; 
			if (_real_events_qnt > 0) {
				for (var t:int = 0; t < _real_events_qnt; t++) {
					if (	_xml.month[par_mnode].day[getCurrentDayNode(par_day)].event[t].type_id == "1") {
						_is_holiday = true;
					}
				}
			}
			if (!(par_obj == "")) {
				for (var m:int = 0; m < par_obj.length; m++) {
					if (par_obj[m].event_type == 1) {
						_is_holiday = true;
					}
				}
			}

			var _type1_realevents:Array = new Array(); // stores the position of the "FERIADO" node, so it is inserted at the end of the list
			var _type1_stevents:Array = new Array();
			
			// processes event data if available in this day - checks if there is a node of events on this day
			if (_real_events_qnt > 0) {

				// inserts itens in the table
				for (var i:int = 0; i < _real_events_qnt; i++) {
					
					// parses event type filter
					if (_data_filter != _xml.month[par_mnode].day[getCurrentDayNode(par_day)].event[i].type_id) {					
												
						// leaves the type 1 event to be inserted in the end of the list
						if (_xml.month[par_mnode].day[getCurrentDayNode(par_day)].event[i].type_id != "1") {
							
							// only includes if is a type 1 event and has permission to put it
							if (_is_holiday) {
								if (_xml.month[par_mnode].day[getCurrentDayNode(par_day)].event[i].end_date.indexOf("FER") != -1) {
									insertEventRow();
								}
							} else { // if it's not a type 1 event, makes other checks
							
								if (getWeekDayNum(_nav_year, _nav_month, par_day) == 0) { // if it's a weekend than has to test to watch for permission in the nodes
									if ((_xml.month[par_mnode].day[getCurrentDayNode(par_day)].event[i].end_date.indexOf("DOM") != -1) || (_xml.month[par_mnode].day[getCurrentDayNode(par_day)].event[i].start_date.indexOf("DOM") != -1)) {
										insertEventRow();
									}
								} else if (getWeekDayNum(_nav_year, _nav_month, par_day) == 6) {
									if ((_xml.month[par_mnode].day[getCurrentDayNode(par_day)].event[i].end_date.indexOf("SAB") != -1) || (_xml.month[par_mnode].day[getCurrentDayNode(par_day)].event[i].start_date.indexOf("SAB") != -1)) {
										insertEventRow();
									}
								} else { // any other days so it has permission
									insertEventRow();
								}

							}
						} else if (_xml.month[par_mnode].day[getCurrentDayNode(par_day)].event[i].type_id == "1") {
							
							_type1_realevents.push(i);
							
						}
					}
					
				}
				
				function insertEventRow():void {
					_data_check = true; // found events
							
					var _table_row:EventTableItem = new EventTableItem("tablerow_", _tablerow_idx, _tablerow_y, _xml.month[par_mnode].day[getCurrentDayNode(par_day)].event[i], _dataview_type);
					_tablerow_y += _table_row.getItemHeight();
					_table_positioner.addChild(_table_row);
					_tablerow_idx++;					
				}
				
			}

			// processes event data from other days that spans through this day
			if (!(par_obj == "")) {

				for (var j:int = 0; j < par_obj.length; j++) {
			
					
					if ((par_mnode != par_obj[j].month_node) || (getCurrentDayNode(par_day) != par_obj[j].day_node)) {

						// parses event type filter
						if (_data_filter != _xml.month[par_obj[j].month_node].day[par_obj[j].day_node].event[par_obj[j].event_node].type_id) {				
							
							// leaves the type 1 event to be inserted in the end of the list
							if (_xml.month[par_obj[j].month_node].day[par_obj[j].day_node].event[par_obj[j].event_node].type_id != "1") {
								
								// this is a holiday
								if (_is_holiday) {
									if (_xml.month[par_obj[j].month_node].day[par_obj[j].day_node].event[par_obj[j].event_node].end_date.indexOf("FER") != -1) {
										insertEventRowB();
									}
								} else {
									
									if (getWeekDayNum(_nav_year, _nav_month, par_day) == 0) { // if it's a weekend than has to test to watch for permission in the nodes
										if (_xml.month[par_obj[j].month_node].day[par_obj[j].day_node].event[par_obj[j].event_node].end_date.indexOf("DOM") != -1) {
											insertEventRowB();
										}
									} else if (getWeekDayNum(_nav_year, _nav_month, par_day) == 6) {
										if (_xml.month[par_obj[j].month_node].day[par_obj[j].day_node].event[par_obj[j].event_node].end_date.indexOf("SAB") != -1) {
											insertEventRowB();
										}
									} else { // any other days so it has permission
										insertEventRowB();
									}
									
								}
								
							} else if (_xml.month[par_obj[j].month_node].day[par_obj[j].day_node].event[par_obj[j].event_node].type_id == "1") {
								_type1_stevents.push(j);
								
							}
							
						}
					}
				}
				
				function insertEventRowB():void {
					
					_data_check = true; // found events
					
					var _table_rowb:EventTableItem = new EventTableItem("tablerowb_", _tablerow_idx, _tablerow_y, _xml.month[par_obj[j].month_node].day[par_obj[j].day_node].event[par_obj[j].event_node], _dataview_type);
					_tablerow_y += _table_rowb.getItemHeight();
					_table_positioner.addChild(_table_rowb);
					_tablerow_idx++;
					
				}
				
			}

			// processes the type 1 events of the real events list
			if (_type1_realevents.length > 0) {
				for (var c:int = 0; c < _type1_realevents.length; c++) {
					
					_data_check = true; // found events

					var _table_rowc:EventTableItem = new EventTableItem("tablerow_", _tablerow_idx, _tablerow_y, _xml.month[par_mnode].day[getCurrentDayNode(par_day)].event[_type1_realevents[c]], _dataview_type);
					_tablerow_y += _table_rowc.getItemHeight();
					_table_positioner.addChild(_table_rowc);
					_tablerow_idx++;
					
				}
			}

			// processes the type 1 events of the other events list

			if (_type1_stevents.length > 0) {				
				for (var d:int = 0; d < _type1_stevents.length; d++) {

					_data_check = true; // found events
						
					var _table_rowd:EventTableItem = new EventTableItem("tablerowd_", _tablerow_idx, _tablerow_y, _xml.month[par_obj[_type1_stevents[d]].month_node].day[par_obj[_type1_stevents[d]].day_node].event[par_obj[_type1_stevents[d]].event_node], _dataview_type);
					_tablerow_y += _table_rowd.getItemHeight();
					_table_positioner.addChild(_table_rowd);
					_tablerow_idx++;
					
				}
			}
		
			// didn't found any events, go to blank table point
			if (!_data_check) {
				var _empty_row:EventTableItem = new EventTableItem("empty_row_", 0, 0, null, _dataview_type);
				_table_positioner.addChild(_empty_row);
			}

			table_footer.y = _table_positioner.y + _table_positioner.height; // sets the table footer y position
			table_footer.width = (_dataview_type == 2) ? 384.5 : 536;
			
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