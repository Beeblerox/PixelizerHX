package pixelizer.components.render;

import nme.display.BitmapData;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import pixelizer.components.PxComponent;
import pixelizer.Pixelizer;
import pixelizer.utils.PxRenderStats;

/**
 * Allows for graphical output using the blit renderer.
 * Can be animated using animation components.
 */
class PxBlitRenderComponent extends PxComponent 
{
	
	private var _bufferTopLeft_:Point;
	private var _globalTopLeft_:Point;
	
	private var _alpha:Float;
	
	private var _matrix:Matrix;
	private var _colorTransform:ColorTransform;
	private var _useColorTransform:Int;
	
	/**
	 * Offsets the bitmap data from the entities postion.
	 */
	public var hotspot:Point;
	/**
	 * Used by the animation component to allow for hotspots for different frames.
	 */
	public var renderOffset:Point;
	/**
	 * Bitmap data of this component. Holds the graphics.
	 */
	public var bitmapData:BitmapData;
	/**
	 * Specifies whether this bitmap data should render at all.
	 */
	public var visible:Bool;
	
	/**
	 * Construcs a new blit render component.
	 * @param	pBitmapData	Bitmap data to use.
	 * @param	pHotspot	Initial hotspot.
	 */
	public function new(?pBitmapData:BitmapData = null, ?pHotspot:Point = null) 
	{
		_alpha = 1;
		_useColorTransform = 0;
		visible = true;
		super();
		
		_bufferTopLeft_ = Pixelizer.pointPool.fetch();
		_globalTopLeft_ = Pixelizer.pointPool.fetch();
		
		renderOffset = Pixelizer.pointPool.fetch();
		renderOffset.x = renderOffset.y = 0;
		
		_matrix = Pixelizer.matrixPool.fetch();
		_colorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
		
		bitmapData = pBitmapData;
		
		hotspot = Pixelizer.pointPool.fetch();
		hotspot.x = hotspot.y = 0;

		if (pHotspot != null) 
		{
			hotspot.x = pHotspot.x;
			hotspot.y = pHotspot.y;
		} 
		else if (pBitmapData != null) 
		{
			hotspot.x = pBitmapData.width / 2;
			hotspot.y = pBitmapData.height / 2;
		}
	}
	
	/**
	 * Clears all resources used.
	 */
	override public function dispose():Void 
	{
		bitmapData = null;
		_colorTransform = null;
		
		Pixelizer.matrixPool.recycle(_matrix);
		_matrix = null;
		
		Pixelizer.pointPool.recycle(renderOffset);
		Pixelizer.pointPool.recycle(hotspot);
		Pixelizer.pointPool.recycle(_bufferTopLeft_);
		Pixelizer.pointPool.recycle(_globalTopLeft_);
		
		renderOffset = null;
		hotspot = null;
		_bufferTopLeft_ = null;
		_globalTopLeft_ = null;
		
		super.dispose();
	}
	
	/**
	 * Renders the component.
	 * @param	pView	Current scene view.
	 * @param	pBitmapData	Bitmap data to render on.
	 * @param	pOffset	Offset from top left.
	 * @param	pRenderStats	Render stats to update.
	 */
	public function render(pView:Rectangle, pBitmapData:BitmapData, pPosition:Point, pRotation:Float, pRenderStats:PxRenderStats):Void 
	{
		if (!visible)
		{
			return;
		}
		
		pRenderStats.totalObjects++;
		
		_globalTopLeft_.x = pPosition.x - (hotspot.x + renderOffset.x);
		_globalTopLeft_.y = pPosition.y - (hotspot.y + renderOffset.y);
		
		// draw self
		if (bitmapData != null) 
		{
			if (_globalTopLeft_.x < pView.right) 
			{
				if (_globalTopLeft_.x + bitmapData.width >= pView.left) 
				{
					if (_globalTopLeft_.y < pView.bottom) 
					{
						if (_globalTopLeft_.y + bitmapData.height >= pView.top) 
						{
							_bufferTopLeft_.x = _globalTopLeft_.x - pView.x;
							_bufferTopLeft_.y = _globalTopLeft_.y - pView.y;
							if (_alpha < 1 || pRotation != 0 || entity.transform.scaleX != 1 || entity.transform.scaleY != 1) 
							{
								_matrix.identity();
								_matrix.translate( -(hotspot.x + renderOffset.x), -(hotspot.y + renderOffset.y));
								if (entity.transform.scaleX != 1 || entity.transform.scaleY != 1)
								{
									_matrix.scale(entity.transform.scaleX, entity.transform.scaleY);
								}
								if (pRotation != 0) 
								{
									_matrix.translate(-entity.transform.pivotOffset.x, -entity.transform.pivotOffset.y);
									_matrix.rotate(pRotation);
									_matrix.translate(entity.transform.pivotOffset.x, entity.transform.pivotOffset.y);
								}
								_matrix.translate(_bufferTopLeft_.x + hotspot.x + renderOffset.x, _bufferTopLeft_.y + hotspot.y + renderOffset.y);
								if (_alpha < 1) 
								{
									pBitmapData.draw(bitmapData, _matrix, _colorTransform);
								} 
								else 
								{
									pBitmapData.draw(bitmapData, _matrix);
								}
							} 
							else 
							{
								pBitmapData.copyPixels(bitmapData, bitmapData.rect, _bufferTopLeft_, null, null, true);
							}
							pRenderStats.renderedObjects++;
						}
					}
				}
			}
		}
	
	}
	
	public var alpha(get_alpha, set_alpha):Float;
	
	/**
	 * Sets the alpha for this component.
	 */
	public function set_alpha(a:Float):Float 
	{
		_alpha = a;
		_colorTransform.alphaOffset = 255 * (_alpha - 1);
		return a;
	}
	
	/**
	 * Returns the alpha for this component.
	 */
	public function get_alpha():Float 
	{
		return _alpha;
	}
	
	/**
	 * Updates the hotspot's position.
	 * @param	pX	X position.
	 * @param	pY	Y position.
	 */
	public function setHotspot(pX:Int, pY:Int):Void 
	{
		hotspot.x = pX;
		hotspot.y = pY;
	}

}