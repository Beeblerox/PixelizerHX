package pixelizer.prefabs.gui;

import pixelizer.components.render.PxTextFieldComponent;
import pixelizer.PxEntity;

/**
 * An entity containing a text field component only.
 * Useful for quickly displaying text.
 * @author Johan Peitz
 */
class PxTextFieldEntity extends PxEntity 
{
	public var textField:PxTextFieldComponent;
	
	/**
	 * Creates a new entity with a text field component.
	 * @param	pText	Initial text to show.
	 * @param	pColor	Color of text.
	 */
	public function new(?pText:String = "", ?pColor:Int = 0x0) 
	{
		super();
		
		textField = cast(addComponent(new PxTextFieldComponent()), PxTextFieldComponent);
		textField.color = pColor;
		textField.text = pText;
	}
	
	/**
	 * Clears all resources used by entity.
	 */
	override public function dispose():Void 
	{
		textField = null;
		super.dispose();
	}

}