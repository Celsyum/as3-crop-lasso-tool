package com.cls
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	[Event(name="cropped",type="com.cls.LassoCrop")]
	
	/**
	 *
	   Copyright (c) 2012 Celsyum "Digital Zombies"
	
	   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
	   to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
	   and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
	   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
	   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
	   IN THE SOFTWARE.
	 * @author Celsyum 2012 Digital Zombies
	 */
	public class LassoCrop extends EventDispatcher
	{
		public static const CROPPED:String = "cropped";
		
		/**
		 * precision in pixels
		 */
		public var precision:Number = 4;
		
		private var _target:DisplayObject;
		private var _points:Vector.<Point>;
		private var _properties:LassoProps;
		private var _draw:Shape;
		private var _finished:Boolean = false;
		private var _mask:Shape;
		
		////////////////////////////// GETTERS AND SETTERS ///////////////////////////////////////
		
		/**
		 * sets target to be cropped
		 */
		public function set target(value:DisplayObject):void
		{
			if (_target)
			{
				if (_draw && _target.stage)
					_target.parent.removeChild(_draw);
				_target.removeEventListener(Event.ADDED_TO_STAGE, init);
			}
			_target = value;
			if (!_target)
			{
				_mask = null;
				return;
			}
			if (_target.stage)
				init();
			else
			{
				_target.addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		/**
		 * set lasso tool properties
		 */
		public function set properties(value:LassoProps):void
		{
			_properties = value;
			if (_target && _target.stage)
				draw_path();
		}
		
		/////////////////////////PUBLIC METHODS /////////////////////////////////////////////
		
		/**
		 * contructor
		 * @param	target DisplayObect(sprite, bitmap...) you want to cropp
		 * @param	properties aditional properties
		 */
		public function LassoCrop(target:DisplayObject = null, properties:LassoProps = null)
		{
			this._properties = properties;
			this._target = target;
			
			if (_target.stage)
				init();
			else
			{
				_target.addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		/**
		 * reset data if you need
		 */
		public function reset():void
		{
			_finished = false;
			_points = new Vector.<Point>();
			_mask = null;
			if (_draw)
				_draw.graphics.clear();
			if (_target) _target.mask = null;
			init();
		}
		
		public function finish():void
		{
			_finished = true;
		}
		
		/**
		 * apply mask
		 * @param	val enable mask ?
		 */
		public function hideSource(val:Boolean):void
		{
			if (!_finished)
				return;
			if (val)
			{
				if (_mask)
					_target.mask = _mask;
				else
					setMask();
			}
			else
				_target.mask = null;
		}
		
		/**
		 * get the cropping result in Bitmap
		 * @param	smoothing should be image be smoothed?
		 * @return
		 */
		public function getResult(smoothing:Boolean = true):Bitmap
		{
			if (_target && _target.stage && _points.length > 0)
			{
				if (!_mask)
					setMask();
				else
					_target.mask = _mask;
				
				var tempm:Matrix = _target.transform.matrix.clone();
				
				_target.transform.matrix = new Matrix();
				var matt:Matrix = tempm.clone();
				matt.invert();
				_mask.transform.matrix = matt;
				
				var rect:Rectangle = _target.getBounds(_target.parent).intersection(_mask.getBounds(_target.parent));
				
				var dat:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
				var mat:Matrix = new Matrix();
				mat.translate( -rect.x + _target.x, -rect.y + _target.y);
				
				dat.draw(_target,mat,null,null,null, true)
				
				var bitmap:Bitmap = new Bitmap(dat, PixelSnapping.ALWAYS);
				
				_target.transform.matrix = tempm;
				setMask();
				bitmap.transform.matrix = tempm;
				return bitmap;
			}
			else
			{
				return null;
			}
		}
		
		////////////////////////PRIVATE METHODS/////////////////////////////////////////////////
		
		/**
		 * sets mask on target
		 */
		private function setMask():void
		{
			if (_points.length < 3 || !_finished)
				return;
			var sh:Shape = new Shape();
			sh.graphics.beginFill(0x161616);
			
			sh.graphics.moveTo(_points[0].x, _points[0].y);
			
			var i:int;
			for (i = 0; i < _points.length; i++)
			{
				sh.graphics.lineTo(_points[i].x, _points[i].y);
			}
			
			sh.graphics.moveTo(_points[0].x, _points[0].y);
			_mask = sh;
			_target.mask = _mask;
		}
		
		/**
		 * initialize method
		 * @param	e
		 */
		private function init(e:Event = null):void
		{
			_target.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_draw = new Shape();
			_target.parent.addChild(_draw);
			_points = new Vector.<Point>();
			_target.stage.addEventListener(MouseEvent.CLICK, onMouse);
			_target.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouse);
		}
		
		/**
		 * handles mouse events
		 * @param	e Mouse event
		 */
		private function onMouse(e:MouseEvent):void
		{
			
			if (_finished)
				return;
			switch (e.type)
			{
				case MouseEvent.CLICK: 
					// TODO: implement double click to close lasso  - Celsyum 2012 Digital Zombies 2012.10.02 01:28
					_points.push(new Point(e.stageX, e.stageY));
					var ln:Number = Math.sqrt(Math.pow(e.stageX - _points[0].x, 2) + Math.pow(e.stageY - _points[0].y, 2));
					if (_points.length > 1 && precision > ln)
					{
						_finished = true;
					}
					break;
				default: 
			}
			
			draw_path();
			if (_finished)
				dispatchEvent(new Event(CROPPED));
		}
		
		/**
		 * draw mask/path to be cropped outline
		 */
		private function draw_path():void
		{
			if (_points.length == 0)
				return;
			if (!_properties)
				_properties = new LassoProps();
			_draw.graphics.clear();
			_draw.graphics.lineStyle(_properties.data.thickness, _properties.data.color, _properties.data.alpha, true);
			
			_draw.graphics.moveTo(_points[0].x, _points[0].y);
			var i:int;
			for (i = 0; i < _points.length; i++)
			{
				_draw.graphics.lineTo(_points[i].x, _points[i].y);
			}
			if (_finished)
			{
				_draw.graphics.lineTo(_points[0].x, _points[0].y);
			}
			else
			{
				_draw.graphics.lineTo(_target.stage.mouseX, _target.stage.mouseY);
			}
		}
	
	}

}