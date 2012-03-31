package examples.nesting;

import flash.geom.Point;
import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.Pixelizer;
import pixelizer.PxEntity;
import pixelizer.PxInput;
import pixelizer.PxScene;
import pixelizer.utils.PxImageUtil;

class NestingExampleScene extends PxScene 
{
	private var _timePassed:Float;
	
	public function new() 
	{
		_timePassed = 0;
		super();
		
		// bg color of scene
		backgroundColor = Pixelizer.COLOR_WHITE;
		
		var i:Int;
		var e:PxEntity;

		e = addEntity(new RotatingEntity(Pixelizer.COLOR_RED, 2));
		e.transform.setPosition(100, 60);
		for (i in 0...4) 
		{
			e = e.addEntity(new RotatingEntity(Pixelizer.COLOR_RED, 2));
			e.transform.setPosition(14, 0);
		}
		
		e = addEntity(new RotatingEntity(Pixelizer.COLOR_GREEN, 1));
		e.transform.setPosition(200, 120);
		for (i in 0...6) 
		{
			e = e.addEntity(new RotatingEntity(Pixelizer.COLOR_GREEN, 1));
			e.transform.setPosition(14, 0);
		}
		
		
		e = addEntity(new RotatingEntity(Pixelizer.COLOR_BLUE, 0.2));
		e.transform.setPosition(100, 180);
		for (i in 0...20) 
		{
			e = e.addEntity(new RotatingEntity(Pixelizer.COLOR_BLUE, 0.2));
			e.transform.setPosition(14, 0);
		}
	}
	
	override public function dispose():Void 
	{
		super.dispose();
	}
	
	override public function update(pDT:Float):Void 
	{
		_timePassed += pDT;
		
		if (PxInput.isPressed(PxInput.KEY_ESC)) 
		{
			engine.popScene();
		}
		
		super.update(pDT);
	}

}