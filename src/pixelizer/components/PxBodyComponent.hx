package pixelizer.components;

import nme.geom.Point;
import pixelizer.Pixelizer;

/**
 * Allows an entity to respond to gravity, have velocity and location.
 */
class PxBodyComponent extends PxComponent 
{
	/**
	 * Denotes that the body is on ground.
	 */
	public static inline var ON_GROUND:Int = 0;
	/**
	 * Denotes that the body is in the air.
	 */
	public static inline var IN_AIR:Int = 1;
	
	/**
	 * Current velocity of this body.
	 */
	public var velocity:Point;
	/**
	 * Mass of this body.
	 */
	public var mass:Float;
	
	/**
	 * The location from last frame.
	 */
	public var lastLocation:Int;
	/**
	 * Position from last frame.
	 */
	public var lastPosition:Point;
	
	private var _location:Int;
	private var _gravity:Point;
	
	/**
	 * Creates a new body component.
	 * @param	pMass	Mass of this body.
	 */
	public function new(?pMass:Float = 1) 
	{
		_location = IN_AIR;
		super();
		
		mass = pMass;
		
		velocity = Pixelizer.pointPool.fetch();
		velocity.x = velocity.y = 0;
		
		lastPosition = Pixelizer.pointPool.fetch();
		lastPosition.x = lastPosition.y = 0;
		
		_gravity = Pixelizer.pointPool.fetch();
		_gravity.x = 0;
		_gravity.y = 1;
	}
	
	/**
	 * Clears all resources used.
	 */
	override public function dispose():Void 
	{
		super.dispose();
		
		Pixelizer.pointPool.recycle(velocity);
		Pixelizer.pointPool.recycle(lastPosition);
		Pixelizer.pointPool.recycle(_gravity);
		
		velocity = null;
		lastPosition = null;
		_gravity = null;
	}
	
	/**
	 * Updates the entity with the velocity in the body.
	 * @param	pDT	Time step.
	 */
	override public function update(pDT:Float):Void 
	{
		super.update(pDT);
		
		lastLocation = _location;
		
		// gravity
		if (location == IN_AIR) 
		{
			velocity.x += _gravity.x * mass;
			velocity.y += _gravity.y * mass;
		}
		
		// move in y
		lastPosition.y = entity.transform.position.y;
		entity.transform.position.y += velocity.y;
		
		// move in x
		lastPosition.x = entity.transform.position.x;
		entity.transform.position.x += velocity.x;
	}
	
	/**
	 * Returns location of this body.
	 * IN_AIR, ON_GROUND.
	 */
	
	public var location(get_location, set_location):Int;
	
	public function get_location():Int 
	{
		return _location;
	}
	
	/**
	 * Sets the location of this body.
	 * IN_AIR, ON_GROUND.
	 */
	public function set_location(value:Int):Int 
	{
		lastLocation = _location;
		_location = value;
		return value;
	}
	
	/**
	 * Sets the gravity for this body.
	 * @param	pX	Gravity along X.
	 * @param	pY	Gravity along Y.
	 */
	public function setGravity(pX:Float, pY:Float):Void 
	{
		_gravity.x = pX;
		_gravity.y = pY;
	}
	
	/**
	 * Sets the velocity for this body.
	 * @param	pVelX	X velocity.
	 * @param	pVelY	Y velocity.
	 */
	public function setVelocity(pVelX:Float, pVelY:Float):Void 
	{
		velocity.x = pVelX;
		velocity.y = pVelY;
	}

}