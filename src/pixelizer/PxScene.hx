package pixelizer;

import pixelizer.components.collision.PxBoxColliderComponent;
import pixelizer.IPxEntityContainer;
import pixelizer.physics.PxCollisionManager;
import pixelizer.render.PxCamera;

/**
 * The scene holds and manages all entities. Scenes are updated by the engine.
 *
 * @author Johan Peitz
 */
class PxScene implements IPxEntityContainer 
{
	private var _entityRoot:PxEntity;
	
	private var _collisionManager:PxCollisionManager;
	
	private var _mainCamera:PxCamera;
	
	/**
	 * Specifies whether the scene has a background fill.
	 */
	public var background:Bool;
	/**
	 * The color of the backround, if any.
	 */
	public var backgroundColor:Int;
	/**
	 * Engine scene is added to.
	 */
	public var engine:PxEngine;
	
	/**
	 * Constructs a new scene.
	 */
	public function new() 
	{
		background = true;
		backgroundColor = 0xFFFFFF;
		
		_entityRoot = new PxEntity();
		_entityRoot.scene = this;
		
		_collisionManager = new PxCollisionManager();
		
		_mainCamera = new PxCamera(Pixelizer.engine.engineWidth, Pixelizer.engine.engineHeight, Math.floor(-Pixelizer.engine.engineWidth / 2), Math.floor(-Pixelizer.engine.engineHeight / 2));
	}
	
	/**
	 * Cleans up all resources used by the scene, including any added entities which will also be disposed.
	 */
	public function dispose():Void 
	{
		_entityRoot.dispose();
		_entityRoot = null;
		
		_mainCamera.dispose();
		_mainCamera = null;
		
		_collisionManager.dispose();
		_collisionManager = null;
		
		engine = null;
	}
	
	/**
	 * Invoked when the scene is added to the engine.
	 * @param	pEngine	The engine the scene is added to.
	 */
	public function onAddedToEngine(pEngine:PxEngine):Void 
	{
		engine = pEngine;
	}
	
	/**
	 * Invoked when the scene is remove from an engine. Disposes the scene.
	 */
	public function onRemovedFromEngine():Void 
	{
		engine = null;
		dispose();
	}
	
	/**
	 * Invoked regularly by the engine. Updates all entities and subsystems.
	 * @param	pDT	Time step in number of seconds.
	 */
	public function update(pDT:Float):Void 
	{
		// update entities
		updateEntityTree(_entityRoot, pDT);
		
		_collisionManager.update(pDT);
		
		if (_mainCamera != null) 
		{
			_mainCamera.update(pDT);
		}
	}
	
	private function updateEntityTree(pEntity:PxEntity, pDT:Float):Void 
	{
		engine.logicStats.entitiesUpdated++;
		
		pEntity.update(pDT);
		
		for (e in pEntity.entities) 
		{
			e.transform.globalPosition.x = pEntity.transform.globalPosition.x + e.transform.position.x;
			e.transform.globalPosition.y = pEntity.transform.globalPosition.y + e.transform.position.y;
			
			updateEntityTree(e, pDT);
		}
		
		if (pEntity.destroy) 
		{
			pEntity.parent.removeEntity(pEntity);
		}
	}
	
	/**
	 * Returns the collision manager for this scene.
	 */
	
	public var collisionManager(get_collisionManager, null):PxCollisionManager;
	
	public function get_collisionManager():PxCollisionManager 
	{
		return _collisionManager;
	}
	
	/**
	 * Returns the camera for this scene.
	 */
	
	public var camera(get_camera, null):PxCamera;
	
	public function get_camera():PxCamera 
	{
		return _mainCamera;
	}
	
	/**
	 * Returns the root entity to which all other entities are added.
	 * @return 	The root entity.
	 */
	
	public var entityRoot(get_entityRoot, null):PxEntity;
	
	public function get_entityRoot():PxEntity 
	{
		return _entityRoot;
	}
	
	/**
	 * Adds and entity to the scene.
	 * @param	pEntity The entity to add.
	 * @return	The entity parameter passed as argument.
	 */
	public function addEntity(pEntity:PxEntity, ?pHandle:String = ""):PxEntity 
	{
		return _entityRoot.addEntity(pEntity, pHandle);
	}
	
	/**
	 * Removes an entity from the scene. The entity will be disposed.
	 * @param	pEntity	The entity to remove.
	 * @return	The entity parameter passed as argument.
	 */
	public function removeEntity(pEntity:PxEntity):PxEntity 
	{
		return _entityRoot.removeEntity(pEntity);
	}
	
	/**
	 * Adds entities of the desired class to the specified vector.
	 * @param	pRootEntity		Root entity of where to start the search. ( E.g. scene.entityRoot )
	 * @param	pEntityClass	The entity class to look for.
	 * @param	pEntityVector	Vector to populate with the results.
	 */
	public function getEntitesByClass(pRootEntity:PxEntity, pEntityClass:Class<PxEntity>, pEntityVector:Array<PxEntity>):Void 
	{
		return _entityRoot.getEntitesByClass(pRootEntity, pEntityClass, pEntityVector);
	}
	
	/**
	 * Adds entities with the specified handle to the specified vector.
	 * @param	pRootEntity	Root entity of where to start the search. ( E.g. scene.entityRoot )
	 * @param	pHandle	Handle to look for.
	 * @param	pEntityVector	Vector to populate with the results.
	 */
	public function getEntitiesByHandle(pRootEntity:PxEntity, pHandle:String, pEntityVector:Array<PxEntity>):Void 
	{
		return _entityRoot.getEntitiesByHandle(pRootEntity, pHandle, pEntityVector);
	}

}