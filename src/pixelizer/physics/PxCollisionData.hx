package pixelizer.physics;

import nme.geom.Point;
import pixelizer.components.collision.PxColliderComponent;

/**
 * Contains data generated when to colliders overlap.
 * @author Johan Peitz
 */
class PxCollisionData 
{
	/**
	 * Collided collider.
	 */
	public var myCollider:PxColliderComponent;
	/**
	 * Collider collided with.
	 */
	public var otherCollider:PxColliderComponent;
	/**
	 * Overlap between colliders.
	 */
	public var overlap:Point;
	
	/**
	 * Creates new collision data.
	 * @param	pMyCollider	Collided collider.
	 * @param	pOtherCollider	Collider collided with.
	 * @param	pOverlap	Overlap between colliders.
	 */
	public function new(?pMyCollider:PxColliderComponent = null, ?pOtherCollider:PxColliderComponent = null, ?pOverlap:Point = null) 
	{
		myCollider = pMyCollider;
		otherCollider = pOtherCollider;
		overlap = pOverlap;
	}
	
	/**
	 * Clear all references this data uses.
	 */
	public function dispose():Void 
	{
		myCollider = otherCollider = null;
		overlap = null;
	}

}