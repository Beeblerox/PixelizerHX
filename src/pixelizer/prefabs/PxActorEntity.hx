package pixelizer.prefabs;

import pixelizer.components.collision.PxBoxColliderComponent;
import pixelizer.components.PxBodyComponent;
import pixelizer.components.render.PxAnimationComponent;
import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.PxEntity;

/**
 * Pre populated entity with the usual components.
 * @author Johan Peitz
 */
class PxActorEntity extends PxEntity 
{
	/**
	 * Render component makes sure something will be seen.
	 */
	public var renderComp:PxBlitRenderComponent;
	/**
	 * Animation component animates the render component.
	 */
	public var animComp:PxAnimationComponent;
	/**
	 * Collider component handles all collision.
	 */
	public var boxColliderComp:PxBoxColliderComponent;
	/**
	 * Body component enables velocities and gravity.
	 */
	public var bodyComp:PxBodyComponent;
	
	/**
	 * Constrcuts a new actor entity.
	 */
	public function new() 
	{
		super();
		renderComp = cast(addComponent(new PxBlitRenderComponent()), PxBlitRenderComponent);
		animComp = cast(addComponent(new PxAnimationComponent()), PxAnimationComponent);
		boxColliderComp = cast(addComponent(new PxBoxColliderComponent(16, 16)), PxBoxColliderComponent);
		bodyComp = cast(addComponent(new PxBodyComponent()), PxBodyComponent);
	}
	
	/**
	 * Clears all resources used by actor.
	 */
	override public function dispose():Void 
	{
		renderComp = null;
		animComp = null;
		boxColliderComp = null;
		bodyComp = null;
		
		super.dispose();
	}

}