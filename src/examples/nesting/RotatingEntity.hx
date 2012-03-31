package examples.nesting;

import flash.geom.Point;
import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.Pixelizer;
import pixelizer.PxEntity;
import pixelizer.utils.PxImageUtil;
import pixelizer.utils.PxMath;

/**
 * ...
 * @author Johan Peitz
 */
class RotatingEntity extends PxEntity 
{
	private var _timePassed:Float;
	private var _rotSpeed:Float;
	private var _color:Int;
	
	public function new(pColor:Int, pRotSpeed:Float) 
	{
		_timePassed = 0;
		_rotSpeed = 1;
		_color = 0;
		super();
		
		_color = pColor;
		_rotSpeed = pRotSpeed;
		transform.scale = 0.95;
		addComponent(new PxBlitRenderComponent(PxImageUtil.createRect(16, 8, _color), new Point(0, 4)));
	}
	
	override public function update(pDT:Float):Void 
	{
		_timePassed += pDT * _rotSpeed;
		transform.rotation = PxMath.sin(_timePassed * 2) * 0.7;
		
		super.update(pDT);
	}

}