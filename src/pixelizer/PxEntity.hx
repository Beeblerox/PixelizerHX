package pixelizer;

import nme.events.EventDispatcher;
import pixelizer.components.PxComponent;
import pixelizer.components.PxTransformComponent;
import pixelizer.IPxEntityContainer;
import pixelizer.PxScene;
import pixelizer.utils.PxArray;

/**
 * Base base class for all entities. Entites have to be added to scenes
 * in order to be updated. Entities can also be nested.
 *
 * @author Johan Peitz
 */
class PxEntity extends EventDispatcher, implements IPxEntityContainer 
{
	private var _destroyInSeconds:Float;
	private var _destroy:Bool;
	
	/**
	 * Scene this entity is added to.
	 */
	public var scene:PxScene;
	
	/**
	 * Transform of this entity.
	 */
	public var transform:PxTransformComponent;
	
	/**
	 * Parent of entity in tree hierarchy.
	 */
	public var parent:IPxEntityContainer;
	/**
	 * Handle for quick access.
	 */
	public var handle:String;
	
	private var _components:Array<PxComponent>;
	private var _entities:Array<PxEntity>;
	private var _entitiesToAdd:Array<PxEntity>;
	private var _entitiesToRemove:Array<PxEntity>;
	
	private var _onRemovedCallbacks:Array<Dynamic>;
	
	/**
	 * Creates a new entity at desired postion.
	 *
	 * @param	pX	X position of entity.
	 * @param	pY	Y position of entity.
	 */
	public function new(?pX:Int = 0, ?pY:Int = 0) 
	{
		_destroyInSeconds = -1;
		_destroy = false;
		super();
		
		_components = new Array<PxComponent>();
		_entities = new Array<PxEntity>();
		_entitiesToAdd = new Array<PxEntity>();
		_entitiesToRemove = new Array<PxEntity>();
		//_entitiesByHandle = new Dictionary();
		
		_onRemovedCallbacks = new Array<Dynamic>();
		
		transform = cast(addComponent(new PxTransformComponent(pX, pY)), PxTransformComponent);
	}
	
	/**
	 * Disposes the entity and it's components. All nested entites are also disposed.
	 */
	public function dispose():Void 
	{	
		removeEntitiesFromQueue();
		_entitiesToRemove = null;
		
		addEntitiesFromQueue();
		_entitiesToAdd = null;
		
		for (e in _entities) 
		{
			e.dispose();
		}
		
		for (c in _components) 
		{
			c.dispose();
		}
		_components = null;
		
		scene = null;
		
		_onRemovedCallbacks = null;
	}
	
	/**
	 * Invoked when entity is added to a scene.
	 *
	 * @param	pScene	Scene which the entity was just added to.
	 */
	public function onAddedToScene(pScene:PxScene):Void 
	{
		scene = pScene;
		for (c in _components) 
		{
			c.onEntityAddedToScene(scene);
		}
		
		for (e in _entities) 
		{
			e.onAddedToScene(scene);
		}
	}
	
	/**
	 * Invoked when entity is removed from a scene.
	 */
	public function onRemovedFromScene():Void 
	{
		for (f in _onRemovedCallbacks) 
		{
			f(this);
		}
		_onRemovedCallbacks = new Array<Dynamic>();
		
		for (c in _components) 
		{
			c.onEntityRemovedFromScene();
		}
		
		for (e in _entities) 
		{
			e.onRemovedFromScene();
		}
		
		scene = null;
	}
	
	/**
	 * Tells the entity to destroy itself in x number of seconds.
	 * Once destroyed the entity will be disposed.
	 *
	 * @param	pSeconds	Number of second until destruction.
	 */
	public function destroyIn(pSeconds:Float):Void 
	{
		if (_destroyInSeconds < 0) 
		{
			_destroyInSeconds = pSeconds;
		}
	}
	
	/**
	 * Adds a component to the entity.
	 *
	 * @param	pComponent	Component to add.
	 * @return	The component parameter passed as argument.
	 */
	public function addComponent(pComponent:PxComponent):PxComponent 
	{
		_components.push(pComponent);
		_components.sort(sortOnPriority);
		pComponent.onAddedToEntity(this);
		
		if (scene != null) 
		{
			pComponent.onEntityAddedToScene(scene);
		}
		
		return pComponent;
	}
	
	/**
	 * Removes a component from the entity. The component will NOT be disposed.
	 * @param	pComponent	Component to remove.
	 * @return	The component paramater passed as argument.
	 */
	public function removeComponent(pComponent:PxComponent):PxComponent 
	{
		if (scene != null) 
		{
			pComponent.onEntityRemovedFromScene();
		}
		
		_components.splice(PxArray.indexOf(_components, pComponent), 1);
		pComponent.onRemovedFromEntity();
		
		return pComponent;
	}
	
	private function sortOnPriority(a:PxComponent, b:PxComponent):Int 
	{
		return a.priority - b.priority;
	}
	
	/**
	 * Adds an entity to the entity, extending the entity tree hierarchy.
	 * @param	pEntity	Entity to add.
	 * @return	The entity parameter passed as argument.
	 */
	public function addEntity(pEntity:PxEntity, ?pHandle:String = ""):PxEntity 
	{
		pEntity.handle = pHandle;
		_entitiesToAdd.push(pEntity);
		
		return pEntity;
	}
	
	/**
	 * Removes an entity from the entity.
	 * @param	pEntity Entity to remove. The entity will be disposed.
	 * @return	The entity parameter passed as argument.
	 */
	public function removeEntity(pEntity:PxEntity):PxEntity 
	{
		_entitiesToRemove.push(pEntity);
		return pEntity;
	}
	
	/**
	 * Adds entities with the specified handle to the specified vector.
	 * @param	pRootEntity	Root entity of where to start the search. ( E.g. scene.entityRoot )
	 * @param	pHandle	Handle to look for.
	 * @param	pEntityVector	Vector to populate with the results.
	 */
	public function getEntitiesByHandle(pRootEntity:PxEntity, pHandle:String, pEntityVector:Array<PxEntity> ):Void 
	{
		if (pRootEntity.handle == pHandle) 
		{
			pEntityVector.push(pRootEntity);
		}
		for (e in pRootEntity.entities) 
		{
			getEntitiesByHandle(e, pHandle, pEntityVector);
		}
	}
	
	/**
	 * Adds entities of the desired class to the specified vector.
	 * @param	pRootEntity		Root entity of where to start the search. ( E.g. scene.entityRoot )
	 * @param	pEntityClass	The entity class to look for.
	 * @param	pEntityVector	Vector to populate with the results.
	 */
	public function getEntitesByClass(pRootEntity:PxEntity, pEntityClass:Class<PxEntity>, pEntityVector:Array<PxEntity>):Void 
	{
		if (Std.is(pRootEntity, pEntityClass)) 
		{
			pEntityVector.push(pRootEntity);
		}
		for (e in pRootEntity.entities) 
		{
			getEntitesByClass(e, pEntityClass, pEntityVector);
		}
	}
	
	/**
	 * Invoked regularly by the scene. Updates all components and nested entities in the entity.
	 * @param	pDT	Time step in number of seconds.
	 */
	public function update(pDT:Float):Void 
	{
		var pos:Int;
		var c:PxComponent;
		
		// add entities
		addEntitiesFromQueue();
		
		pos = _components.length;
		while (--pos >= 0) 
		{
			c = _components[pos];
			c.update(pDT);
		}
		
		// remove entities
		removeEntitiesFromQueue();
		
		// destroy entity
		if (_destroyInSeconds >= 0) 
		{
			_destroyInSeconds -= pDT;
			if (_destroyInSeconds <= 0) 
			{
				_destroy = true;
			}
		}
	}
	
	private function addEntitiesFromQueue():Void 
	{
		var e:PxEntity;
		if (_entitiesToAdd.length > 0) 
		{
			for (e in _entitiesToAdd) 
			{
				_entities.push(e);
				e.parent = this;
				if (scene != null) 
				{
					e.onAddedToScene(scene);
				}
			}
			_entitiesToAdd = new Array<PxEntity>();
		}
	}
	
	private function removeEntitiesFromQueue():Void 
	{
		var pos:Int = _entitiesToRemove.length;
		var e:PxEntity;
		if (pos > 0) {
			while (--pos >= 0) 
			{
				e = _entitiesToRemove[pos];
				_entities.splice(PxArray.indexOf(_entities, e), 1);
				e.onRemovedFromScene();
				e.dispose();
			}
			_entitiesToRemove = new Array<PxEntity>();
		}
	}
	
	/**
	 * Tells wether the entity already has a component of a certain class.
	 * @param	pClass	Component class to check.
	 * @return	True if the entity has a component of this class. False otherwise.
	 */
	public function hasComponentByClass(pClass:Class<PxComponent>):Bool 
	{
		for (c in _components) 
		{
			if (Std.is(c, pClass)) 
			{
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Returns the first found (if any) component of a certain class.
	 * @param	pClass	Component class to look for.
	 * @return	First instance found of requested class. Or null if no such class found.
	 */
	public function getComponentByClass(pClass:Class<PxComponent>):PxComponent 
	{
		for (c in _components) 
		{
			if (Std.is(c, pClass)) 
			{
				return c;
			}
		}
		
		return null;
	}
	
	/**
	 * Returns all components of a certain class.
	 * @param	pClass	Component class to look for.
	 * @return	Vector of components.
	 */
	public function getComponentsByClass(pClass:Class<PxComponent>):Array<PxComponent> 
	{
		var v:Array<PxComponent> = new Array<PxComponent>();
		for (c in _components) 
		{
			if (Std.is(c, pClass)) 
			{
				v.push(c);
			}
		}
		
		return v;
	}
	
	/**
	 * Adds a function which will be called when this entity is removed from the scene.
	 * @param	pFunction	Function to call.
	 */
	public function addOnRemovedCallback(pFunction:Dynamic):Void 
	{
		_onRemovedCallbacks.push(pFunction);
	}
	
	/**
	 * Returns all entities added to this entity.
	 * @return	Vector of entities.
	 */
	
	public var entities(get_entities, null):Array<PxEntity>;
	
	public function get_entities():Array<PxEntity> 
	{
		return _entities;
	}
	
	/**
	 * Checks if entity wants to be destroyed or not.
	 * @return True if entity is listed to be destroyed.
	 */
	
	public var destroy(get_destroy, null):Bool;
	
	public function get_destroy():Bool 
	{
		return _destroy;
	}
}