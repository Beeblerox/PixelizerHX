package pixelizer.prefabs.logo;

import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.PxEntity;
import pixelizer.utils.PxImageUtil;

/**
 * Entity used in animating the Pixelizer logo. Displays a colored square.
 * @author Johan Peitz
 */
class PxLogoPixelEntity extends PxEntity 
{
	
	private var _x:Float;
	private var _y:Float;
	private var _z:Float;
	private var _3DFactor:Float;
	private var _rendComp:PxBlitRenderComponent;
	private var _fall:Bool;
	private var _fallTimer:Float;
	private var _vy:Float;
	
	public function new(pX:Int, pY:Int, pZ:Float, pSize:Int, pColor:Int) 
	{
		_fall = false;
		_fallTimer = 0;
		_vy = 0;
		
		super(pX, pY);
		
		_x = pX;
		_y = pY;
		_z = pZ;
		
		_3DFactor = 256;
		
		_rendComp = cast(addComponent(new PxBlitRenderComponent(PxImageUtil.createRect(pSize, pSize, pColor))), PxBlitRenderComponent);
		
		calcPseudo3DTransform();
	}
	
	override public function dispose():Void 
	{
		_rendComp = null;
		super.dispose();
	}
	
	override public function update(pDT:Float):Void 
	{
		if (_z < _3DFactor) 
		{
			_z += 360 * pDT;
		}
		if (_z > _3DFactor) 
		{
			_z = _3DFactor;
		}
		
		if (_fallTimer > 0) 
		{
			_fallTimer -= pDT;
			if (_fallTimer <= 0) 
			{
				_fall = true;
				_vy = -90 - Math.random() * 30;
			}
		}
		if (_fall) 
		{
			_vy += 720 * pDT;
		}
		
		_y += _vy * pDT;
		
		calcPseudo3DTransform();
		super.update(pDT);
	}
	
	private function calcPseudo3DTransform():Void 
	{
		_rendComp.visible = (_z > 0);
		if (_rendComp.visible) 
		{
			transform.position.x = (_x * _3DFactor) / _z;
			transform.position.y = (_y * _3DFactor) / _z;
			transform.scale = 1 * _3DFactor / _z;
		}
	}
	
	public function fallIn(pSeconds:Float):Void 
	{
		_fallTimer = pSeconds;
	}

}