package pixelizer.components;

import pixelizer.PxEntity;
import pixelizer.PxScene;

/**
 * Base class for all components.
 * @author Johan Peitz
 */
class PxComponent 
{
	/**
	 * Entity which this component is added to.
	 */
	public var entity:PxEntity;
	/**
	 * Update priority for this component.
	 */
	public var priority:Int;
	
	public function new()
	{
		priority = 0;
	}
	
	/**
	 * Clears all resources used by this component.
	 */
	public function dispose():Void 
	{
		entity = null;
	}
	
	/**
	 * Invoked when added to an entity.
	 * @param	pEntity	Entity added to.
	 */
	public function onAddedToEntity(pEntity:PxEntity):Void 
	{
		entity = pEntity;
	}
	
	/**
	 * Invoked when removed from an entity.
	 */
	public function onRemovedFromEntity():Void 
	{
		entity = null;
	}
	
	/**
	 * Invoked when the entity the component belongs to is added to a scene.
	 * @param	pScene	Scene the entity was added to.
	 */
	public function onEntityAddedToScene(pScene:PxScene):Void {  }
	
	/**
	 * Invoked when the entity the component belongs to is removed from a scene.
	 */
	public function onEntityRemovedFromScene():Void {  }
	
	/**
	 * Invoked regularly by the entity.
	 * @param	pDT	Time step.
	 */
	public function update(pDT:Float):Void {  }

}