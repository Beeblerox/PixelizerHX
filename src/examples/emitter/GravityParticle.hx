package examples.emitter;

import pixelizer.components.PxBodyComponent;
import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.Pixelizer;
import pixelizer.PxEntity;
import pixelizer.utils.PxImageUtil;
import pixelizer.utils.PxMath;

class GravityParticle extends PxEntity 
{
	private var _body:PxBodyComponent;
	private var _roundsPerSecond:Float;
	
	public function new() 
	{
		super();
		
		var colors:Array<Int> = [Pixelizer.COLOR_RED, Pixelizer.COLOR_GREEN, Pixelizer.COLOR_BLUE];
		addComponent(new PxBlitRenderComponent(PxImageUtil.createRect(8, 8, colors[PxMath.randomInt(0, 3)])));
		_body = cast(addComponent(new PxBodyComponent(1)), PxBodyComponent);
		_roundsPerSecond = PxMath.TWO_PI * PxMath.randomNumber(-10, 10);
	}
	
	override public function dispose():Void 
	{
		_body = null;
		super.dispose();
	}
	
	override public function update(pDT:Float):Void 
	{
		// add some friction to speeds
		_body.velocity.x *= 0.9;
		
		transform.rotation += pDT * _roundsPerSecond;
		
		super.update(pDT);
	}
}