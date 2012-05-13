package pixelizer.components.collision;

import pixelizer.physics.PxAABB;

/**
 * Collider consiting of a simple box.
 */
class PxBoxColliderComponent extends PxColliderComponent 
{
	/**
	 * Axis Aliged Bounding Box for this collider.
	 */
	public var collisionBox:PxAABB;
	
	/**
	 * Constructs a new box collider.
	 * @param	pWidth	Width of box.
	 * @param	pHeight	Height of box.
	 * @param	pSolid	Specifies whether collider should be solid or not.
	 */
	public function new(pWidth:Float, pHeight:Float, ?pSolid:Bool = true) 
	{
		super(pSolid);
		collisionBox = new PxAABB(pWidth, pHeight, pWidth / 2, pHeight / 2);
	}
	
	/**
	 * Clears all resources used by collider.
	 */
	override public function dispose():Void 
	{
		collisionBox = null;
		super.dispose();
	}
	
	/**
	 * Sets the size of the collision box.
	 * @param	pWidth	Width of box.
	 * @param	pHeight	Height of box.
	 */
	public function setSize(pWidth:Float, pHeight:Float):Void 
	{
		collisionBox.halfWidth = pWidth / 2;
		collisionBox.halfHeight = pHeight / 2;
		collisionBox.offsetX = pWidth / 2;
		collisionBox.offsetY = pHeight / 2;
	}

}