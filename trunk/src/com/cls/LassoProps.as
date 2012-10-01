package com.cls 
{
	/**
	 * class to handle properties
	 * @author Celsyum 2012 Digital Zombies
	 */
	public class LassoProps 
	{
		public var data:Object;
		
		/**
		 * contructor
		 */
		public function LassoProps() 
		{
			data = { };
			data.thickness = null;
			data.color = 0;
			data.alpha = 1;
		}
		
		/**
		 * define lasso tool line thickness
		 * @param	val
		 * @return
		 */
		public function lineThickness(val:int = NaN):LassoProps 
		{
			data.thickness = val;
			return this;
		}
		
		/**
		 * define line color
		 * @param	val
		 * @return
		 */
		public function lineColor(val:uint = 0):LassoProps
		{
			data.color = val;
			return this;
		}
		
		/**
		 * define line alpha
		 * @param	val
		 * @return
		 */
		public function lineAlpha(val:Number = 1):LassoProps
		{
			data.alpha = val;
			return this;
		}
	}

}