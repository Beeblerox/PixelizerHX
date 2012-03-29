package pixelizer.render;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObject;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.Lib;
import pixelizer.components.PxComponent;
import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.Pixelizer;
import pixelizer.PxEntity;
import pixelizer.PxScene;
import pixelizer.utils.PxMath;
import pixelizer.utils.PxRenderStats;

/**
 * Pixelizer renderer that uses blitting to position bitmap data onto a destination bitmap.
 * @author Johan Peitz
 */
class PxBlitRenderer implements IPxRenderer 
{
	private var _surface:Bitmap;
	private var _renderStats:PxRenderStats;
	
	private var _view:Rectangle;
	
	/**
	 * Construcs a new blit renderer.
	 * @param	pWidth	Width of output bitmap.
	 * @param	pHeight	Height of output bitmap.
	 * @param	pScale	Scale of output bitmap.
	 */
	public function new(pWidth:Int, pHeight:Int, ?pScale:Int = 1) 
	{
		_surface = new Bitmap(new BitmapData(pWidth, pHeight, false, 0xFFFFFF));
		_surface.scaleX = _surface.scaleY = pScale;
		_surface.smoothing = false;
		
		_renderStats = new PxRenderStats();
		
		_view = new Rectangle();
	}
	
	/**
	 * Clears all used resources.
	 */
	public function dispose():Void 
	{
		if (_surface.parent != null) 
		{
			_surface.parent.removeChild(_surface);
		}
		_surface.bitmapData.dispose();
		_surface = null;
		_view = null;
	
	}
	
	/**
	 * Invoked before rendering starts.
	 */
	public function beforeRendering():Void 
	{
		_renderStats.reset();
		_renderStats.renderTime = Lib.getTimer();
		_surface.bitmapData.lock();
	}
	
	/**
	 * Renders a scene. The renderer will go through the entity tree in order and render
	 * any PxBlitRenderComponents found.
	 * @param	pScene	Scene to render.
	 */
	public function render(pScene:PxScene):Void 
	{
		// clear bitmap data
		if (pScene.background) 
		{
			_surface.bitmapData.fillRect(_surface.bitmapData.rect, pScene.backgroundColor);
		}
		
		if (pScene.camera != null) 
		{
			_view.width = pScene.camera.view.width;
			_view.height = pScene.camera.view.height;
			renderRenderComponents(pScene.entityRoot, pScene, pScene.entityRoot.transform.position, pScene.entityRoot.transform.rotation);
		}
	}
	
	private function renderRenderComponents(pEntity:PxEntity, pScene:PxScene, pPosition:Point, pRotation:Float):Void 
	{
		_view.x = pScene.camera.view.x * pEntity.transform.scrollFactorX;
		_view.y = pScene.camera.view.y * pEntity.transform.scrollFactorY;
		
		for (e in pEntity.entities) 
		{
			var pos:Point = Pixelizer.pointPool.fetch();
			if (pRotation != 0) 
			{
				// TODO: find faster versions of sqrt and atan2
				var d:Float = Math.sqrt(e.transform.position.x * e.transform.position.x + e.transform.position.y * e.transform.position.y);
				var a:Float = Math.atan2(e.transform.position.y, e.transform.position.x) + pRotation;
				pos.x = pPosition.x + d * PxMath.cos(a);
				pos.y = pPosition.y + d * PxMath.sin(a);
			} 
			else 
			{
				pos.x = pPosition.x + e.transform.position.x;
				pos.y = pPosition.y + e.transform.position.y;
			}
			
			var brcs:Array<PxComponent> = e.getComponentsByClass(PxBlitRenderComponent);
			for (brc in brcs) 
			{
				cast(brc, PxBlitRenderComponent).render(_view, _surface.bitmapData, pos, pRotation + e.transform.rotation, _renderStats);
			}
			
			renderRenderComponents(e, pScene, pos, pRotation + e.transform.rotation);
			Pixelizer.pointPool.recycle(pos);
		}
	}
	
	/**
	 * Invoked before when rendering is completed.
	 */
	public function afterRendering():Void 
	{
		_surface.bitmapData.unlock();
		_renderStats.renderTime = Lib.getTimer() - _renderStats.renderTime;
	}
	
	/**
	 * Returns the display object for this renderer.
	 * @return Display object for this renderer.
	 */
	
	public var displayObject(get_displayObject, null):DisplayObject;
	
	public function get_displayObject():DisplayObject 
	{
		return _surface;
	}
	
	/**
	 * Returns the latest stats for the rendering.
	 * @return Stats of the latest rendering.
	 */
	
	public var renderStats(get_renderStats, null):PxRenderStats;
	
	public function get_renderStats():PxRenderStats 
	{
		return _renderStats;
	}

}