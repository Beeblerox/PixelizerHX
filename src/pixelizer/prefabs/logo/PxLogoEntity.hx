package pixelizer.prefabs.logo;

import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.Pixelizer;
import pixelizer.PxEntity;
import pixelizer.PxInput;
import pixelizer.utils.PxImageUtil;

/**
 * Entity displaying animated Pixelizer logo.
 * @author Johan Peitz
 */
class PxLogoEntity extends PxEntity 
{
	
	private var _logoData:String;
	
	private var _logoColors:Array<Int>;
	private var _timePassed:Float;
	private var _fadeOut:Bool;
	private var _bg:PxBlitRenderComponent;
	
	private var _onLogoComplete:Dynamic;
	
	private var _pixelSize:Int;
	
	public function new(?pOnCompleteCallback:Dynamic = null) 
	{
		_logoData = "0111111111111111111111111100" + "1000000000000000000000000010" + "1022034042223004222333440015" + "1020204042003000002300404015" + "1020230402203004020330404015" + "1022034042003004200300440015" + "1020034042223334222333404015" + "1000000000000000000000000015" + "0111111111111111111110011155" + "0055555555555555555510155550" + "0000000000000000000011550000" + "0000000000000000000015500000" + "0000000000000000000005000000";
		_logoColors = [ Pixelizer.COLOR_WHITE, Pixelizer.COLOR_BLACK, Pixelizer.COLOR_RED, Pixelizer.COLOR_GREEN, Pixelizer.COLOR_BLUE, Pixelizer.COLOR_GRAY ];
		_fadeOut = false;
		_pixelSize = 5;
		super();
		
		_onLogoComplete = pOnCompleteCallback;
		// big white background
		_bg = cast(addComponent(new PxBlitRenderComponent(PxImageUtil.createRect(Pixelizer.engine.engineWidth, Pixelizer.engine.engineHeight, 0xFFFFFF))), PxBlitRenderComponent);
		// create pixel entities
		for (y in 0...13) 
		{
			for (x in 0...28) 
			{
				var c:Int = Std.parseInt(_logoData.substr(x + y * 28, 1));
				if (c > 0) 
				{
					var z:Float = -x * 10 + y * 10 - 200 - 30 * Math.random();
					var e:PxLogoPixelEntity = new PxLogoPixelEntity((x - 14) * _pixelSize, (y - 10) * _pixelSize, z, _pixelSize - 1, _logoColors[c]);
					e.fallIn(3 + x / 20 + (13 - y) / 30 + Math.random() / 5);
					addEntity(e);
				}
			}
		}
		
		transform.setPosition(Pixelizer.engine.engineWidth / 2, Pixelizer.engine.engineHeight / 2);
		
		_timePassed = 0;
		Pixelizer.engine.resetTimers();
	}
	
	override public function dispose():Void 
	{
		_bg = null;
		super.dispose();
	}
	
	override public function update(pDT:Float):Void 
	{
		_timePassed += pDT;
		
		if (_fadeOut) 
		{
			if (_bg.alpha > 0) 
			{
				_bg.alpha -= pDT * 10;
			}
		} 
		else 
		{
			if (PxInput.isPressed(PxInput.KEY_ESC) || PxInput.mousePressed) 
			{
				_fadeOut = true;
				for (e in entities) 
				{
					e.destroyIn(0);
				}
				destroyIn(1);
				if (_onLogoComplete != null) 
				{
					_onLogoComplete();
				}
			} 
			else if (_timePassed > 5.2 && !_fadeOut) 
			{
				_fadeOut = true;
				destroyIn(1);
				if (_onLogoComplete != null) 
				{
					_onLogoComplete();
				}
			}
		}
		
		super.update(pDT);
	}

}