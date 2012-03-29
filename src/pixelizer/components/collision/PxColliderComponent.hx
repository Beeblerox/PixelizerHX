package pixelizer.components.collision;

import pixelizer.PxScene;
import pixelizer.physics.PxCollisionData;
import pixelizer.utils.PxArray;

import pixelizer.components.PxComponent;

/**
 * The collider component acts as base class for all types of collisions.
 * Each collider can belong to any number of collision layers. This is handled by
 * a bit mask. By changing the collider's mask or the mask which controls which
 * layers the collider collides with, various useful effects can be achieved.
 *
 * @author Johan Peitz
 */
class PxColliderComponent extends PxComponent 
{
	/**
	 * What layer(s) this component belongs to.
	 */
	#if flash
	public var collisionLayer:UInt;
	#else
	public var collisionLayer:Int;
	#end
	/**
	 * What layer(s) this component collides with.
	 */
	#if flash
	public var collisionLayerMask:UInt;
	#else
	public var collisionLayerMask:Int;
	#end
	
	/**
	 * Specifies whether this collider is solid or just a trigger.
	 */
	public var solid:Bool;
	
	/**
	 * Callback invoked when a collision starts.
	 */
	private var _onCollisionStartCallback:Dynamic;
	/**
	 * Callback invoked every frame the collision lasts (except the first).
	 */
	private var _onCollisionOngoingCallback:Dynamic;
	/**
	 * Callback invoked when a collision ends.
	 */
	private var _onCollisionEndCallback:Dynamic;
	
	private var _currentColliders:Array<PxColliderComponent>;
	
	/**
	 * Constructs a new collider.
	 * @param	pSolid	Specifies whether collider should be solid.
	 */
	public function new(?pSolid:Bool = true) 
	{
		collisionLayer = 0;
		collisionLayerMask = 0;
		solid = true;
		
		super();
		
		_currentColliders = new Array<PxColliderComponent>();
		
		solid = pSolid;
		
		priority = -1;
	}
	
	/**
	 * Clears all resources used by collider.
	 */
	override public function dispose():Void 
	{
		_currentColliders = null;
		_onCollisionStartCallback = _onCollisionOngoingCallback = _onCollisionEndCallback = null;
	}
	
	/**
	 * Invoked when collider's entity is added to scene.
	 * Automatically adds the collider to the scene's collision manager.
	 * @param	pScene	Scene entity was added to.
	 */
	override public function onEntityAddedToScene(pScene:PxScene):Void 
	{
		entity.scene.collisionManager.addCollider(this);
	}
	
	/**
	 * Invoked when collider's entity is removed from scene.
	 * Automatically removed the collider from the scene's collision manager.
	 * @param	pScene	Scene entity was removed from.
	 */
	override public function onEntityRemovedFromScene():Void 
	{
		entity.scene.collisionManager.removeCollider(this);
	}
	
	/**
	 * Adds a collider to the current list of active collisions.
	 * Invoked by the collision manager.
	 * @param	pCollider	Collider to add.
	 */
	public function addCollidingCollider(pCollider:PxColliderComponent):Void 
	{
		_currentColliders.push(pCollider);
	}
	
	/**
	 * Remove a collider from the current list of active collisions.
	 * Invoked by the collision manager.
	 * @param	pCollider	Collider to remove.
	 */
	public function removeCollidingCollider(pCollider:PxColliderComponent):Void 
	{
		_currentColliders.splice(PxArray.indexOf(_currentColliders, pCollider), 1);
	}
	
	/**
	 * Checks whether a collider is already in this collider's collider list.
	 * @param	pCollider	Collider to look for.
	 * @return	True if collider was found.
	 */
	public function hasCollidingCollider(pCollider:PxColliderComponent):Bool 
	{
		return PxArray.indexOf(_currentColliders, pCollider) != -1;
	}
	
	/**
	 * Allows an entity to get callbacks when ever this collider updates it's collision status.
	 * @param	pOnCollisionStartCallback	Function called on first contact.
	 * @param	pOnCollisionOngoingCallback	Function called on repeated contact.
	 * @param	pOnCollisionEndCallback		Function called on lost contact.
	 */
	public function registerCallbacks(?pOnCollisionStartCallback:Dynamic = null, ?pOnCollisionOngoingCallback:Dynamic = null, ?pOnCollisionEndCallback:Dynamic = null):Void 
	{
		_onCollisionStartCallback = pOnCollisionStartCallback;
		_onCollisionOngoingCallback = pOnCollisionOngoingCallback;
		_onCollisionEndCallback = pOnCollisionEndCallback;
	}
	
	/**
	 * Invoked by collision manager when a new collision occurs.
	 * @param	pCollisionData	Data containing collision info.
	 */
	public function onCollisionStart(pCollisionData:PxCollisionData):Void 
	{
		if (_onCollisionStartCallback != null) 
		{
			_onCollisionStartCallback(pCollisionData);
		}
	}
	
	/**
	 * Invoked by collision manager every frame as long a collision keeps happning.
	 * @param	pCollisionData	Data containing collision info.
	 */
	public function onCollisionOngoing(pCollisionData:PxCollisionData):Void 
	{
		if (_onCollisionOngoingCallback != null) 
		{
			_onCollisionOngoingCallback(pCollisionData);
		}
	}
	
	/**
	 * Invoked by collision manager when a collision ends.
	 * @param	pCollisionData	Data containing collision info.
	 */
	public function onCollisionEnd(pCollisionData:PxCollisionData):Void 
	{
		if (_onCollisionEndCallback != null) 
		{
			_onCollisionEndCallback(pCollisionData);
		}
	}

}