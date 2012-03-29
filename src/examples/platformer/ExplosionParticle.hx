package examples.platformer;

import pixelizer.components.PxBodyComponent;
import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.PxEntity;
import pixelizer.utils.PxImageUtil;
import pixelizer.utils.PxMath;

/**
 * ...
 * @author Johan Peitz
 */
class ExplosionParticle extends PxEntity 
{
	private var _body:PxBodyComponent;
	
	public function new(?pLifeTime:Float = 1, ?pColor:Int = -1) 
	{
		super();
		
		addComponent(new PxBlitRenderComponent(PxImageUtil.createRect(4, 4, pColor)));
		_body = cast(addComponent(new PxBodyComponent(0)), PxBodyComponent);
		
		var a:Float = Math.random() * PxMath.TWO_PI;
		var f:Float = 5 + Math.random() * 2;
		_body.velocity.x = f * PxMath.cos(a);
		_body.velocity.y = f * PxMath.sin(a);
		
		// don't live longer than this!
		destroyIn(pLifeTime);
	}
	
	override public function dispose():Void 
	{
		_body = null;
		super.dispose();
	}
	
	public function setVelocity(pVX:Float, pVY:Float):Void 
	{
		_body.velocity.x = pVX;
		_body.velocity.y = pVY;
	}
	
	override public function update(pDT:Float):Void 
	{
		_body.velocity.x *= 0.95;
		_body.velocity.y *= 0.95;
		
		super.update(pDT);
	}
}