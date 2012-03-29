package pixelizer.physics;

import nme.geom.Point;

/**
 * An Axis Aligned Boundinx Box. Can also be offsetted.
 * @author Johan Peitz
 */
class PxAABB 
{
	
	/**
	 * Half the with of box.
	 */
	public var halfWidth:Float;
	/**
	 * Half the height of box.
	 */
	public var halfHeight:Float;
	
	/**
	 * X offset from whatever collider this box belongs to.
	 */
	public var offsetX:Float;
	/**
	 * Y offset from whatever collider this box belongs to.
	 */
	public var offsetY:Float;
	
	/**
	 * Constructs a new Axis Aligned Bounding box.
	 * @param	pWidth	Width of box;
	 * @param	pHeight	Height of box.
	 * @param	pOffsetX	X offset for box.
	 * @param	pOffsetY	Y offset for box.
	 */
	public function new(?pWidth:Float = 0, ?pHeight:Float = 0, ?pOffsetX:Float = 0, ?pOffsetY:Float = 0 ) 
	{
		halfWidth = pWidth / 2;
		halfHeight = pHeight / 2;
		offsetX = pOffsetX;
		offsetY = pOffsetY;
	}

}