package examples.gui;

import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.Pixelizer;
import pixelizer.prefabs.gui.PxGUIButton;
import pixelizer.prefabs.gui.PxMouseEntity;
import pixelizer.prefabs.gui.PxTextFieldEntity;
import pixelizer.PxInput;
import pixelizer.PxScene;
import pixelizer.utils.PxImageUtil;
import pixelizer.utils.PxLog;

/**
 * ...
 * @author Johan Peitz
 */
class GUIExampleScene extends PxScene 
{
	private var _button:PxGUIButton;
	private var _buttonClicks:Int;
	
	public function new() 
	{
		_buttonClicks = 0;
		super();
		
		_button = new PxGUIButton("Click me!", onButtonClicked);
		_button.transform.setPosition(100, 100);
		addEntity(_button);
		
		var mouseEnt:PxMouseEntity = new PxMouseEntity();
		mouseEnt.addComponent(new PxBlitRenderComponent(PxImageUtil.createRect(3, 3, Pixelizer.COLOR_RED)));
		addEntity(mouseEnt);
	
	}
	
	override public function dispose():Void 
	{
		_button = null;
		super.dispose();
	}
	
	public function onButtonClicked(pBbutton:PxGUIButton):Void 
	{
		_buttonClicks++;
		_button.label = _buttonClicks + " clicks";
	}
	
	override public function update(pDT:Float):Void 
	{
		
		if (PxInput.isPressed(PxInput.KEY_ESC)) 
		{
			engine.popScene();
		}
		
		super.update(pDT);
	}

}