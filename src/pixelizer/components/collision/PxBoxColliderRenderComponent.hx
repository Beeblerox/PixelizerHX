package pixelizer.components.collision;

import flash.display.BitmapData;
import pixelizer.components.collision.PxBoxColliderComponent;
import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.utils.PxLog;

/**
 * Renders a box collider. Add this component to an entity to have it's box collider render automatically.
 * @author Johan Peitz
 */
class PxBoxColliderRenderComponent extends PxBlitRenderComponent 
{
	private var _boxColliderComp:PxBoxColliderComponent;

	/**
	 * Constructs a new PxBoxColliderRenderComponent.
	 */
	public function new() 
	{
		super();
		alpha = 0.5;
	}

	/**
	 * Disposes all resources used by component.
	 */
	override public function dispose():Void 
	{
		_boxColliderComp = null;
		super.dispose();
	}

	/**
	 * Updates the component.
	 * @param	pDT	Time step in seconds.
	 */
	override public function update(pDT:Float):Void 
	{
		// get collider info
		if (_boxColliderComp == null) 
		{
			_boxColliderComp = cast(entity.getComponentByClass(PxBoxColliderComponent), PxBoxColliderComponent);
		}

		// use collider info
		if (_boxColliderComp != null) 
		{
			if (bitmapData != null) 
			{
				bitmapData.dispose();
			}
			bitmapData = new BitmapData(Math.floor(_boxColliderComp.collisionBox.halfWidth * 2), Math.floor(_boxColliderComp.collisionBox.halfHeight * 2), false, 0xFF00FF);
			
			setHotspot(Math.floor(_boxColliderComp.collisionBox.halfWidth - _boxColliderComp.collisionBox.offsetX), Math.floor(_boxColliderComp.collisionBox.halfHeight - _boxColliderComp.collisionBox.offsetY));
		}

		// keep calm and carry on
		super.update(pDT);
	}
	
}