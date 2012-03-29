package examples.emitter;

import pixelizer.components.PxBodyComponent;
import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.Pixelizer;
import pixelizer.PxEntity;
import pixelizer.utils.PxImageUtil;
import pixelizer.utils.PxMath;

class NoGravityParticle extends PxEntity 
{
	private var _body:PxBodyComponent;
	
	public function new() 
	{
		super();
		
		var colors:Array<Int> = [Pixelizer.COLOR_RED, Pixelizer.COLOR_GREEN, Pixelizer.COLOR_BLUE];
		addComponent(new PxBlitRenderComponent(PxImageUtil.createCircle(4, colors[PxMath.randomInt(0, 3)])));
		_body = cast(addComponent(new PxBodyComponent(0)), PxBodyComponent);
	}
	
	override public function dispose():Void 
	{
		_body = null;
		super.dispose();
	}
	
	override public function update(pDT:Float):Void 
	{
		// add some friction to speeds
		_body.velocity.x *= 0.85;
		_body.velocity.y *= 0.85;
		//
		super.update(pDT);
	}
}