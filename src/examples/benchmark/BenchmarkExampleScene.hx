package examples.benchmark;

//import examples.assets.AssetFactory;
//import examples.collision.CollisionExampleScene;
//import examples.emitter.EmittersExampleScene;
//import examples.input.InputExampleScene;
//import examples.platformer.PlatformerTitleScene;
//import examples.sound.SoundExampleScene;
//import examples.text.TextExampleScene;
//import examples.transform.TransformExampleScene;

import nme.display.BitmapData;
import nme.Assets;

import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.physics.PxCollisionSolver;
import pixelizer.Pixelizer;
import pixelizer.prefabs.gui.PxTextFieldEntity;
import pixelizer.PxEngine;
import pixelizer.PxEntity;
import pixelizer.PxInput;
import pixelizer.PxScene;
import pixelizer.utils.PxMath;

class BenchmarkExampleScene extends PxScene 
{
	
	private var _testEntities:Array<PxEntity>;
	private var _infoText:PxTextFieldEntity;
	private var _mode:Int;
	
	public function new() 
	{
		_testEntities = [];
		_mode = 0;
		super();
		
		// specify bg color
		backgroundColor = Pixelizer.COLOR_WHITE;
		
		// image to use
		var bd:BitmapData = Assets.getBitmapData("assets/pickups.png"); // AssetFactory.pickups;
		
		// position examples
		var e:PxEntity;
		for (i in 0...500) 
		{
			e = new PxEntity(PxMath.randomInt(0, 320), PxMath.randomInt(0, 240));
			e.addComponent(new PxBlitRenderComponent(bd));
			addEntity(e);
			_testEntities.push(e);
		}
		
		_infoText = new PxTextFieldEntity();
		_infoText.transform.setPosition(0, 100);
		_infoText.textField.padding = 2;
		_infoText.textField.background = true;
		addEntity(_infoText);
	
	}
	
	override public function dispose():Void 
	{
		_testEntities = null;
		_infoText = null;
		super.dispose();
	}
	
	override public function update(pDT:Float):Void 
	{
		var e:PxEntity;
		
		if (PxInput.isPressed(PxInput.KEY_ESC)) 
		{
			engine.popScene();
		}
		
		if (PxInput.isPressed(PxInput.KEY_Q)) 
		{
			if ((_mode & 1) != 0) 
			{
				_mode &= ~1;
				for (e in _testEntities) 
				{
					e.transform.scaleY = 1;
				}
			} 
			else 
			{
				_mode |= 1;
				for (e in _testEntities) 
				{
					e.transform.scaleY = -1;
				}
			}
		}
		
		if (PxInput.isPressed(PxInput.KEY_W)) 
		{
			if ((_mode & 2) != 0) 
			{
				_mode &= ~2;
				for (e in _testEntities) 
				{
					e.transform.rotation = 0;
				}
			} 
			else 
			{
				_mode |= 2;
				for (e in _testEntities) 
				{
					e.transform.rotation = PxMath.HALF_PI / 2;
				}
			}
		}
		
		if (PxInput.isPressed(PxInput.KEY_E)) 
		{
			if ((_mode & 4) != 0) 
			{
				_mode &= ~4;
				for (e in _testEntities) 
				{
					cast(e.getComponentByClass(PxBlitRenderComponent), PxBlitRenderComponent).alpha = 1;
				}
			} 
			else 
			{
				_mode |= 4;
				for (e in _testEntities) 
				{
					cast(e.getComponentByClass(PxBlitRenderComponent), PxBlitRenderComponent).alpha = 0.5;
				}
			}
		}
		
		var renderStr:String = "Press Q,W,E to toggle modes.\n\n";
		if ((_mode & 1) != 0)
		{
			renderStr += "[ SCALE FLIP ] ";
		}
		if ((_mode & 2) != 0)
		{
			renderStr += "[ ROTATION ] ";
		}
		if ((_mode & 4) != 0)
		{
			renderStr += "[ ALPHA ] ";
		}
		_infoText.textField.text = renderStr + "\n\nRendering " + engine.renderer.renderStats.renderedObjects + " objects in " + engine.renderer.renderStats.renderTime + " ms";
		
		super.update(pDT);
	}

}