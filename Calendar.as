/**
 * Calendar
 * Calendar application for the home of PUCRS institutional site
 *
 * @author		Giliar Perez
 * @version		2.0.5
 
 * 19/5/2008
 * Added "ATE" as a string parameter
 */

package {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.display.LoaderInfo;
	

	public class Calendar extends MovieClip {
		
		/**
		 * Parameters
		 *
		 * @param		_calendar_so			Stores local data - the selected data view type button
		 * @param		_xml_container		Container for main XML data
		 * @param		_dataview_type		Type of data view type. <code>1</code> for horizontal (default) mode, <code>2</code> for classic calendar mode
		 * @param		_xml_file					Name of XML file to be loaded
		 */
		private var _calendar_so:SharedObject = SharedObject.getLocal("pucrs-calendar");
		private var _xml_container:XML = new XML();
		private var _dataview_type:int;
		private var _xml_file:String;
		//private var _xml_file:String = "http://www3.pucrs.br/portal/pls/portal/portal_admin.xml_calendar";
		//private var _xml_file:String = "portal_admin.xml";
		private var _firstrun_check:Boolean = true;
		private var _initial_data_filter:int = 0;
		
		/**
		 * Class constructor
		 */
		public function Calendar():void {
			
			// parses parameters data
			var embed_str:Object = LoaderInfo(root.loaderInfo).parameters;
			var key_str:String;
			for (key_str in embed_str) {
				_xml_file = String(embed_str[key_str]);
			}
			//_xml_file = "calendar.xml";
			
			// defines actions for data view type buttons
			/*
			bt_dataview_hor.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {setDataViewType(e.target.name)});
			bt_dataview_hor.buttonMode = true;
			bt_dataview_cla.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {setDataViewType(e.target.name)});
			bt_dataview_cla.buttonMode = true;
			*/
			bt_dataview_hor.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {flipDataView(e.target.name)});
			bt_dataview_hor.buttonMode = true;
			bt_dataview_cla.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {flipDataView(e.target.name)});
			bt_dataview_cla.buttonMode = true;
						
			xmlParser(_xml_file); // loads data and starts calendar build
					
			/* debug button actions */
			/*
			debug_bt.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				var _calendar_so:SharedObject = SharedObject.getLocal("pucrs-calendar");
				_calendar_so.clear();
			});
			*/
		}
				
		/**
		 * Processes shared object data to build last selected data view
		 */
		 private function processSharedObject():void {
			 if (getSOData() == null) {
				 setSOData("bt_dataview_cla");
				 setDataViewType("bt_dataview_cla");
			 } else {
				 setDataViewType(getSOData());
			 }
		 }
		
		/**
		 * Proceeds with the XML parsing when movie reaches
		 */
		 /* CUSTOM DISPATCHER
		public function set x(value:Number):void {
		    super.x = value;
		    dispatchEvent(new Event(Event.CHANGE));
		}
		*/
		public function flipDataView(p_str):void {

			setDataViewType(p_str);

			//removeChildAt(1); // removes previous table
			var _idx:int = getChildIndex(getChildByName("event_viewer"));
			removeChildAt(_idx);
			
			/*
			var _ddidx:int = getChildIndex(getChildByName("drop_dn"));
			removeChildAt(_ddidx);
			*/
			xmlParser(_xml_file); // re-processes XML data
			
		}
		
		/**
		 * Sets the current data view type
		 */
		 private function setDataViewType(par_id:String):void {
			root[getSOData()].gotoAndStop(1);  // switches the last clicked button to 'up' state
			root[par_id].gotoAndStop(2); // marks the clicked button 'on'
			setSOData(par_id); // assigns current clicked button name to the sharedobject
			_dataview_type = (par_id == "bt_dataview_hor") ? 1 : 2; // sets the data view type

			/*
			if (!_firstrun_check) {
				//transitioner.gotoAndPlay(1);
				flipDataView();
			}
			*/
						
			_firstrun_check = false;
		 }		
		 
		/**
		 * Filter events in the list
		*/
		public function set filterEvents(param_idx:int):void {
			var _temp_var:int = (param_idx == 0) ? 0 : param_idx + 1;
			EventViewer(getChildByName("event_viewer")).setEventFilter(_temp_var);
			_initial_data_filter = _temp_var;
		}
		 
		 /**
		* Inserts drop down
		*/
		private function insertDropDown():void {
			var _items_array:Array = new Array("de Eventos e Acadêmico", "apenas de Eventos", "apenas Acadêmico");
			var drop_down:DropDown = new DropDown(90.5, 8.5, _items_array, "filterEvents");
			drop_down.name = "drop_dn";
			addChildAt(drop_down, 5);
		}
		 
		 /**
		* Returns the local sharedobject data
		*/
		private function getSOData():String {
			var _calendar_so:SharedObject = SharedObject.getLocal("pucrs-calendar");
			return _calendar_so.data.dataview_type;
		}
		 
		private function setSOData(param_i:String):void {
			var _calendar_so:SharedObject = SharedObject.getLocal("pucrs-calendar");
			_calendar_so.data.dataview_type = param_i;
			_calendar_so.flush();
		}
		 
		/**
		* XML parser
		*/
		private function xmlParser(par_xml:String):void {
			_xml_container.ignoreWhitespace = false; // ignores whitespaces in xml file
			var _xml_url:String = par_xml; // filename
			var _xml_url_request:URLRequest = new URLRequest(_xml_url);
			
			var _xml_loader:URLLoader = new URLLoader(_xml_url_request);
			_xml_loader.addEventListener(Event.COMPLETE, XMLLoaded);	
			
			function XMLLoaded(event:Event):void { // listener function
				_xml_container = XML(_xml_loader.data);
				
				insertDropDown(); // adds dropdown
				
				processSharedObject(); // processes last clicked data view type 

				var _event_viewer:EventViewer = new EventViewer(10.5, 33.5, _xml_container, _dataview_type, _initial_data_filter); // creates main calendar content (eventviewer)
				_event_viewer.name = "event_viewer";
				addChildAt(_event_viewer, 1);
				
				 var _temp:FullEventList = new FullEventList(_xml_container);
				
			}
		}
	
	}
	
}