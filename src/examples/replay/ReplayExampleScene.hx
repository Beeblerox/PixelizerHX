package examples.replay;

import pixelizer.Pixelizer;
import pixelizer.prefabs.gui.PxTextFieldEntity;
import pixelizer.PxInput;
import pixelizer.PxScene;

/**
 * ...
 * @author Johan Peitz
 */
class ReplayExampleScene extends PxScene 
{

	private var _currentEntity:ReplayEntity;
	
	public function new() 
	{
		super();
		
		var text:PxTextFieldEntity = new PxTextFieldEntity("Arrows to move box. SPACE to create new box.");
		text.textField.alignment = Pixelizer.CENTER;
		text.textField.width = 320;
		text.transform.position.y = 10;
		addEntity(text);

		spawnEntity();
	}
	
	private function spawnEntity():Void 
	{
		if (_currentEntity != null) 
		{
			_currentEntity.replay();
		}
		_currentEntity = new ReplayEntity();
		addEntity(_currentEntity);
	}
	
	override public function update(pDT:Float):Void 
	{
		if (PxInput.isPressed(PxInput.KEY_SPACE)) 
		{
			spawnEntity();
		}
		
		if (PxInput.isPressed(PxInput.KEY_ESC)) 
		{
			engine.popScene();
		}
		
		super.update(pDT);
	}

}