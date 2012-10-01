package com.cls 
{
	/**
	 * ...
	 * @author Celsyum 2012 Digital Zombies
	 */
	public class LassoProps 
	{
		public var data:Object;
		
		public function LassoProps() 
		{
			data = { };
			data.thickness = null;
			data.color = 0;
			data.alpha = 1;
		}
		
		public function lineThickness(val:int = NaN):LassoProps 
		{
			data.thickness = val;
			return this;
		}
		
		public function lineColor(val:uint = 0):LassoProps
		{
			data.color = val;
			return this;
		}
		
		public function lineAlpha(val:Number = 1):LassoProps
		{
			data.alpha = val;
			return this;
		}
	}

}