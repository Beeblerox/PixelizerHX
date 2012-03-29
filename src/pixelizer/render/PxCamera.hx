package pixelizer.render;

import nme.geom.Point;
import nme.geom.Rectangle;
import pixelizer.Pixelizer;
import pixelizer.PxEntity;

/**
 * The camera decides what part and size of the scene will be rendered.
 * @author Johan Peitz
 */
class PxCamera 
{
	private var _view:Rectangle;
	private var _bounds:Rectangle;
	private var _lookAt:Point;
	private var _lookOffset:Point;
	private var _targetEntity:PxEntity;
	
	/**
	 * Current center of camera.
	 */
	public var center:Point;
	
	/**
	 * Creates a new camera.
	 * @param	pWidth	Width of view.
	 * @param	pHeight	Height of view.
	 * @param	pOffsetX	Amount to offset the camera along th X axis.
	 * @param	pOffsetY	Amount to offset the camera along th Y axis.
	 */
	public function new(?pWidth:Int = 0, ?pHeight:Int = 0, ?pOffsetX:Int = 0, ?pOffsetY:Int = 0) 
	{
		if (pWidth == 0 || pHeight == 0) 
		{
			pWidth = Pixelizer.engine.engineWidth;
			pHeight = Pixelizer.engine.engineHeight;
		}
		_view = new Rectangle(0, 0, pWidth, pHeight);
		_bounds = null;
		_lookAt = new Point();
		_lookOffset = new Point(pOffsetX, pOffsetY);
		center = new Point();
	}
	
	/**
	 * Clears all resources used by the camera.
	 */
	public function dispose():Void 
	{
		_view = null;
		_bounds = null;
		_lookAt = null;
		_targetEntity = null;
		center = null;
	}
	
	/**
	 * Sets the bounding rectangle for the camera. The camera will not be able to move outside the bounds.
	 * @param	pTopLeft	Top left corner of restricting rectangle.
	 * @param	pBottomRight	Bottom right corner of restricting rectangle.
	 */
	public function setBounds(pTopLeft:Point, pBottomRight:Point):Void 
	{
		_bounds = new Rectangle(pTopLeft.x, pTopLeft.y, pBottomRight.x - pTopLeft.x, pBottomRight.y - pTopLeft.y);
	}
	
	/**
	 * Sets the camera to track a certain entity.
	 * @param	pEntity
	 */
	public function track(pEntity:PxEntity):Void 
	{
		_targetEntity = pEntity;
	}
	
	/**
	 * Invoked regularly by the scene the camera belogns to. Updates camera postion.
	 * @param	pDT
	 */
	public function update(pDT:Float):Void 
	{
		if (_targetEntity != null) 
		{
			_lookAt.x = _targetEntity.transform.position.x;
			_lookAt.y = _targetEntity.transform.position.y;
			lookAt(_lookAt);
		}
		
		center.x = _view.x - _lookOffset.x;
		center.y = _view.y - _lookOffset.y;
	}
	
	/**
	 * Sets the camera to look at a specific position.
	 * @param	pPos	Position to look at.
	 */
	public function lookAt(pPos:Point):Void 
	{
		_view.x = Math.floor(pPos.x + _lookOffset.x);
		_view.y = Math.floor(pPos.y + _lookOffset.y);
		
		if (_bounds != null) 
		{
			if (_view.x < _bounds.x)
			{
				_view.x = _bounds.x;
			}
			if (_view.right > _bounds.right)
			{
				_view.x = _bounds.right - _view.width;
			}
			
			if (_view.y < _bounds.y)
			{
				_view.y = _bounds.y;
			}
			if (_view.bottom > _bounds.bottom)
			{
				_view.y = _bounds.bottom - _view.height;
			}
		}
	}
	
	/**
	 * Returns the camera's current view.
	 * @return The current view.
	 */
	
	public var view(get_view, null):Rectangle;
	
	public function get_view():Rectangle 
	{
		return _view;
	}

}