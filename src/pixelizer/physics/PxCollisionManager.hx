package pixelizer.physics;

import nme.geom.Point;
import pixelizer.components.collision.PxBoxColliderComponent;
import pixelizer.components.collision.PxColliderComponent;
import pixelizer.components.collision.PxGridColliderComponent;
import pixelizer.components.PxBodyComponent;
import pixelizer.utils.PxArray;
import pixelizer.utils.PxCollisionStats;

/**
 * Manages collision between colliders of all types. Each scene has their own collision manager.
 * @author Johan Peitz
 */
class PxCollisionManager 
{
	private var _colliders:Array<PxColliderComponent>;
	private var _overlap:Point;
	
	/**
	 * Stats collected during collision tests.
	 */
	public var collisionStats:PxCollisionStats;
	
	/**
	 * Creats a new collision manager.
	 */
	public function new() 
	{
		_colliders = new Array<PxColliderComponent>();
		_overlap = new Point();
		
		collisionStats = new PxCollisionStats();
	}
	
	/**
	 * Clears all resources used by this manager.
	 */
	public function dispose():Void 
	{
		_colliders = null;
	}
	
	/**
	 * Adds a collider to the manager. The collider will now be check for collision against other colliders.
	 * @param	pCollider	Collider to add.
	 */
	public function addCollider(pCollider:PxColliderComponent):Void 
	{
		_colliders.push(pCollider);
	}
	
	/**
	 * Removes a collider from the manager. It will no longer collide with other colliders.
	 * @param	pCollider	Collider to remove.
	 */
	public function removeCollider(pCollider:PxColliderComponent):Void 
	{
		_colliders.splice(PxArray.indexOf(_colliders, pCollider), 1);
	}
	
	/**
	 * Invoked regularly by the scene. Detects and responds to all collisions between colliders.
	 * @param	pDT
	 */
	public function update(pDT:Float):Void 
	{
		var a:PxColliderComponent;
		var b:PxColliderComponent;
		var len:Int = _colliders.length;
		var collisionDataA:PxCollisionData = new PxCollisionData();
		var collisionDataB:PxCollisionData = new PxCollisionData();
		
		collisionStats.reset();
		collisionStats.colliderObjects = len;
		
		for (i in 0...(len)) 
		{
			a = _colliders[i];
			for (j in (i + 1)...(len)) 
			{
				b = _colliders[j];
				collisionStats.collisionTests++;
				
				if ((a.collisionLayerMask & b.collisionLayer) != 0 || (a.collisionLayer & b.collisionLayerMask) != 0) 
				{
					collisionStats.collisionMasks++;
					
					collisionDataA.myCollider = a;
					collisionDataA.otherCollider = b;
					collisionDataA.overlap = detectAndResolveCollision(a, b);
					
					collisionDataB.myCollider = b;
					collisionDataB.otherCollider = a;
					collisionDataB.overlap = collisionDataA.overlap;
					
					if (collisionDataA.overlap != null) 
					{
						collisionStats.collisionHits++;
						if (a.hasCollidingCollider(b)) 
						{
							a.onCollisionOngoing(collisionDataA);
							b.onCollisionOngoing(collisionDataB);
						} 
						else 
						{
							a.onCollisionStart(collisionDataA);
							b.onCollisionStart(collisionDataB);
							
							a.addCollidingCollider(b);
							b.addCollidingCollider(a);
						}
					} 
					else 
					{
						if (a.hasCollidingCollider(b)) 
						{
							a.onCollisionEnd(collisionDataA);
							b.onCollisionEnd(collisionDataB);
							
							a.removeCollidingCollider(b);
							b.removeCollidingCollider(a);
						}
					}
				}
			}
		}
		
		collisionDataA.dispose();
		collisionDataB.dispose();
	}
	
	private function detectAndResolveCollision(a:PxColliderComponent, b:PxColliderComponent):Point 
	{
		var c:PxColliderComponent;
		if (Std.is(a, PxGridColliderComponent)) 
		{
			c = a;
			a = b;
			b = c;
		}
		
		if (Std.is(a, PxBoxColliderComponent)) 
		{
			if (Std.is(b, PxBoxColliderComponent)) 
			{
				return boxToBox(cast(a, PxBoxColliderComponent), cast(b, PxBoxColliderComponent));
			} 
			else if (Std.is(b, PxGridColliderComponent)) 
			{
				return boxToGrid(cast(a, PxBoxColliderComponent), cast(b, PxGridColliderComponent));
			}
		}
		
		return null;
	}
	
	private function boxToBox(a:PxBoxColliderComponent, b:PxBoxColliderComponent):Point 
	{
		var _overlap:Point = PxCollisionSolver.boxBoxOverlap(a, b);
		if (_overlap.x == 0 || _overlap.y == 0) 
		{
			// overlaps only on one axis, no collision!
			return null;
		}
		
		// push in the smallest direction (if both boxes are solid)
		if (a.solid && b.solid) 
		{
			if (Math.abs(_overlap.x) > Math.abs(_overlap.y)) 
			{
				a.entity.transform.position.y -= _overlap.y / 2;
				b.entity.transform.position.y += _overlap.y / 2;
			} 
			else 
			{
				a.entity.transform.position.x -= _overlap.x / 2;
				b.entity.transform.position.x += _overlap.x / 2;
			}
		}
		
		return _overlap;
	}
	
	private function boxToGrid(a:PxBoxColliderComponent, b:PxGridColliderComponent):Point 
	{
		var collision:Bool = false;
		var bodyComp:PxBodyComponent = null;
		
		var overlap:Point;
		
		var nextPosition:Point = a.entity.transform.position.clone();
		
		var resolveCollision:Bool = a.solid && b.solid;
		
		if (resolveCollision) 
		{
			bodyComp = cast(a.entity.getComponentByClass(PxBodyComponent ), PxBodyComponent);
			if (bodyComp != null)
			{
				a.entity.transform.position.x = bodyComp.lastPosition.x;
			}
		}
		
		_overlap.x = _overlap.y = 0;
		
		// vertical test
		overlap = PxCollisionSolver.boxGridOverlap(a, b, PxCollisionSolver.VERTICAL);
		if (overlap.y != 0) 
		{
			collision = true;
			_overlap.y = overlap.y;
			
			if (resolveCollision) 
			{
				a.entity.transform.position.y += overlap.y;
				if (bodyComp != null)
				{
					bodyComp.velocity.y = 0;
				}
			}
		}
		
		// horizontal test
		a.entity.transform.position.x = nextPosition.x;
		overlap = PxCollisionSolver.boxGridOverlap(a, b, PxCollisionSolver.HORIZONTAL);
		if (overlap.x != 0) 
		{
			collision = true;
			_overlap.x = overlap.x;
			
			if (resolveCollision) 
			{
				a.entity.transform.position.x += overlap.x;
				if (bodyComp != null)
				{
					bodyComp.velocity.x = 0;
				}
			}
		}
		
		if (collision) 
		{
			return _overlap;
		}
		
		return null;
	}

}