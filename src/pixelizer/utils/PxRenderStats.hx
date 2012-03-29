package pixelizer.utils;

/**
 * Holder for stats collected during the rendering.
 * @author Johan Peitz
 */
class PxRenderStats 
{
	/**
	 * Amount of objects actually rendered.
	 */
	public var renderedObjects:Int;
	/**
	 * Total amount of objects.
	 */
	public var totalObjects:Int;
	
	/**
	 * Render time in seconds.
	 */
	public var renderTime:Int;
	
	public function new()
	{
		renderedObjects = 0;
		totalObjects = 0;
		renderTime = 0;
	}
	
	/**
	 * Resets the render stats before each run.
	 */
	public function reset():Void 
	{
		renderedObjects = 0;
		totalObjects = 0;
		renderTime = 0;
	}

}