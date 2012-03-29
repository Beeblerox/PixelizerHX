package pixelizer.render;

import nme.display.DisplayObject;
import pixelizer.PxScene;
import pixelizer.utils.PxRenderStats;

/**
 * Defines the behaviour of a Pixelizer renderer.
 * @author Johan Peitz
 */
interface IPxRenderer 
{
	/**
	 * Renders a scene.
	 * @param	pScene	Scene to render.
	 */
	function render(pScene:PxScene):Void;
	
	/**
	 * Returns the display object for the renderer. The display object contains the visible result of each render pass.
	 */
	public var displayObject(get_displayObject, null):DisplayObject;
	//function get displayObject():DisplayObject;
	
	/**
	 * Returns the stats of the render pass.
	 */
	public var renderStats(get_renderStats, null):PxRenderStats;
	//function get renderStats():PxRenderStats;
	
	/**
	 * Invoked before rendering starts.
	 */
	function beforeRendering():Void;
	/**
	 * Invoked after all rendering is done.
	 */
	function afterRendering():Void;
}