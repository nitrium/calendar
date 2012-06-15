package {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.geom.Rectangle;
	
	public class Scrollbar extends MovieClip {

		// Variables
		private var target_mc:String;
		private var target_mask:String;
		private var target_height:int;
		private var mask_height:int;
		private var target_inity:int;
		private var track_height:int;
		private var knob_mid_height:int;
		private var top_limit:int;
		private var bottom_limit:int;
		private var scroll_direction:int;
		private var init_mask_y:int; // original y position of mask mc
		private var init_target_y:int; // original y position of target mc
		private var init_x:int; // initial x position of elements of the scroll
		private var init_y:int; // initial y position of elements of the scroll
		private var scrollable_cont:int; // total scrollable content
		
		
		// Constants
		private var SCROLL_SPEED:int = 5;
		private var MIN_KNOB_H:int = 17;
		private var LOOP_TIMER:int = 50;
		
		// Misc
		var loop_timer:Timer = new Timer(LOOP_TIMER);
		
		// Rule-of-three
		private function RoT(a:int, b:int, c:int):int {
			return (b*c)/a;
		}
		
		// Disables all scroll functions
		public function disableScroll():void {
			scroll_bt_up.removeEventListener(MouseEvent.MOUSE_OVER, upButton);
			scroll_bt_up.removeEventListener(MouseEvent.MOUSE_OUT, upButton);
			scroll_bt_up.removeEventListener(MouseEvent.MOUSE_DOWN, upButton);
			scroll_bt_up.removeEventListener(MouseEvent.MOUSE_UP, upButton);
			scroll_bt_up.buttonMode = false;
			scroll_bt_up.gotoAndStop(5);
			scroll_bt_dn.removeEventListener(MouseEvent.MOUSE_OVER, downButton);
			scroll_bt_dn.removeEventListener(MouseEvent.MOUSE_OUT, downButton);
			scroll_bt_dn.removeEventListener(MouseEvent.MOUSE_DOWN, downButton);
			scroll_bt_dn.removeEventListener(MouseEvent.MOUSE_UP, downButton);
			scroll_bt_dn.buttonMode = false;
			scroll_bt_dn.gotoAndStop(5);
			scroll_knob.removeEventListener(MouseEvent.MOUSE_OVER, knobButton);
			scroll_knob.removeEventListener(MouseEvent.MOUSE_OUT, knobButton);
			scroll_knob.removeEventListener(MouseEvent.MOUSE_DOWN, knobButton);
			scroll_knob.removeEventListener(MouseEvent.MOUSE_UP, knobButton);
			scroll_knob.buttonMode = false;
			scroll_knob.visible = false;
			track_mc.removeEventListener(MouseEvent.CLICK, trackClick);
			track_mc.buttonMode = false;
			track_mc.gotoAndStop(4);
		}
		
		// Control of content scroll
		private function scrollControl():void {
			parent.getChildByName(target_mc).y = -(((scrollable_cont + 2)*(scroll_knob.y - init_y))/((track_height) - (scroll_knob.height + scroll_bt_up.height + scroll_bt_dn.height)) - init_target_y);
		}
		
		// Detects mouse release outside button area
		private function mouseRelease(e:MouseEvent):void {
			if (e.target == scroll_knob) {
			} else {
					scroll_knob.removeEventListener(Event.ENTER_FRAME, callbackScrollKnob);
					scroll_knob.stopDrag();
					loop_timer.stop();
			}
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseRelease);			
		}

		// Callback functions for  scroll movement
		private function callbackScrollKnob(e:Event):void {
			scrollControl();
		}
		
		// knob movement
		private function moveKnob(e:TimerEvent):void {
			// keeps the scroll inbounds
			if ((scroll_knob.y <= top_limit) && (scroll_direction == -1)) {
				scroll_knob.y = top_limit;
			} else if ((scroll_knob.y >= bottom_limit) && (scroll_direction == 1)) {
				scroll_knob.y = bottom_limit;
			} else {
				scroll_knob.y += SCROLL_SPEED*scroll_direction;
			}
			scrollControl();
		}
		
		// Handles track click
		private function trackClick(e:MouseEvent):void {
			var y_val:int = e.localY;
			if (y_val < (scroll_bt_up.height + (scroll_knob.height/2))) {
				scroll_knob.y = top_limit;
			} else if ((y_val + scroll_bt_up.height) > (track_height - (scroll_bt_dn.height + (scroll_knob.height/2)))) {
				scroll_knob.y = bottom_limit;
			} else {
				scroll_knob.y = y_val;
			}
			scrollControl(); // calls scroll function
		}
		
		// Handles up button actions
		private function upButton(e:MouseEvent):void {
			switch (e.type) {
				case "mouseOver":
					e.target.gotoAndStop(3);
					break;
				case "mouseOut":
					e.target.gotoAndStop(1);
					break;
				case "mouseDown":
					e.target.gotoAndStop(4);
					scroll_direction = -1;
					loop_timer.start();
					stage.addEventListener(MouseEvent.MOUSE_UP, mouseRelease);
					break;
				case "mouseUp":
					e.target.gotoAndStop(1);
					loop_timer.stop();
					break;
			}
		}
		
		// Handles up button actions
		private function downButton(e:MouseEvent):void {
			switch (e.type) {
				case "mouseOver":
					e.target.gotoAndStop(3);
					break;
				case "mouseOut":
					e.target.gotoAndStop(1);
					break;
				case "mouseDown":
					e.target.gotoAndStop(4);
					scroll_direction = 1;
					loop_timer.start();
					stage.addEventListener(MouseEvent.MOUSE_UP, mouseRelease);
					break;
				case "mouseUp":
					e.target.gotoAndStop(1);
					loop_timer.stop();
					break;
			}
		}
		
		// Handles scroll button
		private function knobButton(e:MouseEvent):void {
			switch (e.type) {
				case "mouseOver":
					e.currentTarget.knob_bg.gotoAndStop(3);
					break;
				case "mouseOut":
					e.currentTarget.knob_bg.gotoAndStop(1);
					break;
				case "mouseDown":
					e.currentTarget.knob_bg.gotoAndStop(4);
					var bounding_rect:Rectangle = new Rectangle(init_x, top_limit, 0, (bottom_limit - scroll_bt_dn.height));
					e.currentTarget.startDrag(false, bounding_rect);
					e.currentTarget.addEventListener(Event.ENTER_FRAME, callbackScrollKnob);
					stage.addEventListener(MouseEvent.MOUSE_UP, mouseRelease);
					break;
				case "mouseUp":
					e.currentTarget.stopDrag();
					e.currentTarget.removeEventListener(Event.ENTER_FRAME, callbackScrollKnob);
					e.currentTarget.knob_bg.gotoAndStop(1);
					break;
			}
		}
		
		// Adjusts the track height
		private function scrollHeight():void {
			// disables scroll knob, as the content is smaller than the mask
			if (scrollable_cont <= 0) {
				disableScroll();
			} else if (target_height < (mask_height*2)) { // sets the height if the content is not high enough
				scroll_knob.knob_bg.height = Math.round(track_height/2);
				scroll_knob.knob_mid.y = (scroll_knob.knob_bg.height-knob_mid_height)/2;
			} else {
				var knob_height:int = Math.round(RoT(MIN_KNOB_H*100, track_height, target_height)); // calculates new knob height
				// avoids the knob being too thin
				if (knob_height >= (track_height - (scroll_bt_up.height + scroll_bt_dn.height))) {
					scroll_knob.knob_bg.height = MIN_KNOB_H;
				} else {
					scroll_knob.knob_bg.height = knob_height;
				}
				scroll_knob.knob_mid.y = (scroll_knob.height-knob_mid_height)/2;
			}
			
			bottom_limit = bottom_limit - scroll_knob.height; // final adjustment for bottom y limit
				
		}
		
		// Called when the scrollbar is inserted in the stage
		public function initializeScroll(par_target:String, par_mask:String):void {
			
			target_mc = par_target;
			target_mask = par_mask;
			
			// gets y and h values
			target_height = parent.getChildByName(par_target).height;
			mask_height = parent.getChildByName(par_mask).height;
			target_inity = parent.getChildByName(par_target).y;
			track_height = track_mc.height;
			knob_mid_height = scroll_knob.knob_mid.height;
			top_limit = scroll_bt_up.height;
			bottom_limit = track_height - scroll_bt_dn.height;
			init_x = scroll_knob.x;
			init_y = scroll_knob.y;
			init_target_y = parent.getChildByName(target_mc).y;
			init_mask_y = parent.getChildByName(target_mask).y;
			scrollable_cont = target_height - mask_height;
			
			// button actions
			scroll_bt_up.addEventListener(MouseEvent.MOUSE_OVER, upButton);
			scroll_bt_up.addEventListener(MouseEvent.MOUSE_OUT, upButton);
			scroll_bt_up.addEventListener(MouseEvent.MOUSE_DOWN, upButton);
			scroll_bt_up.addEventListener(MouseEvent.MOUSE_UP, upButton);
			scroll_bt_up.buttonMode = true;
			scroll_bt_dn.addEventListener(MouseEvent.MOUSE_OVER, downButton);
			scroll_bt_dn.addEventListener(MouseEvent.MOUSE_OUT, downButton);
			scroll_bt_dn.addEventListener(MouseEvent.MOUSE_DOWN, downButton);
			scroll_bt_dn.addEventListener(MouseEvent.MOUSE_UP, downButton);
			scroll_bt_dn.buttonMode = true;
			scroll_knob.addEventListener(MouseEvent.MOUSE_OVER, knobButton);
			scroll_knob.addEventListener(MouseEvent.MOUSE_OUT, knobButton);
			scroll_knob.addEventListener(MouseEvent.MOUSE_DOWN, knobButton);
			scroll_knob.addEventListener(MouseEvent.MOUSE_UP, knobButton);
			scroll_knob.mouseChildren = false;
			scroll_knob.buttonMode = true;
			
			// track click actions
			track_mc.addEventListener(MouseEvent.CLICK, trackClick);
			track_mc.buttonMode = true;
			
			// scroll_knob.addEventListener(Event.RENDER, scrollControl); // calls function when it is changed
			loop_timer.addEventListener(TimerEvent.TIMER, moveKnob); // handles mouse press actions
			
			scrollHeight(); // defines scroll area height

		}
		
		// Ajusts the scrollbar size (track)
		public function adjustHeight(par_h:int):void {
			track_mc.height = par_h;
			scroll_bt_dn.y = par_h;
		}
		
		// Constructor
		public function Scrollbar(par_x:int, par_y:int):void {
		
			// scrollbar position
			this.x = par_x;
			this.y = par_y;
			
		}
	}
}