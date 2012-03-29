package pixelizer.utils;

/**
 * Holder for stats collected during the collision phase.
 * @author Johan Peitz
 */
class PxCollisionStats 
{
	/**
	 * Amount of collider objects there are.
	 */
	public var colliderObjects:Int;
	/**
	 * Amount of tests where started.
	 */
	public var collisionTests:Int;
	/**
	 * Amount of tests which passed the mask test.
	 */
	public var collisionMasks:Int;
	/**
	 * Amount of tests which detected a collision.
	 */
	public var collisionHits:Int;
	
	public function new() {  }
	
	/**
	 * Resets the stats for a new round of testing.
	 */
	public function reset():Void 
	{
		colliderObjects = 0;
		collisionTests = 0;
		collisionMasks = 0;
		collisionHits = 0;
	}
}