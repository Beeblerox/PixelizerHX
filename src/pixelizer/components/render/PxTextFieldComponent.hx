package pixelizer.components.render;

import nme.display.BitmapData;
import pixelizer.Pixelizer;
import pixelizer.render.PxBitmapFont;

/**
 * Renders a text field.
 * @author Johan Peitz
 */
class PxTextFieldComponent extends PxBlitRenderComponent 
{
	private var _font:PxBitmapFont;
	private var _text:String;
	private var _color:Int;
	private var _outline:Bool;
	private var _outlineColor:Int;
	private var _shadow:Bool;
	private var _shadowColor:Int;
	private var _background:Bool;
	private var _backgroundColor:Int;
	private var _alignment:Int;
	private var _padding:Int;
	
	private var _pendingTextChange:Bool;
	private var _fieldWidth:Int;
	private var _multiLine:Bool;
	
	/**
	 * Constructs a new text field component.
	 */
	public function new() 
	{
		_text = "";
		_color = 0x0;
		_outline = false;
		_outlineColor = 0x0;
		_shadow = false;
		_shadowColor = 0x0;
		_background = false;
		_backgroundColor = 0xFFFFFF;
		_alignment = Pixelizer.LEFT;
		_padding = 0;
		_pendingTextChange = false;
		_fieldWidth = 1;
		_multiLine = false;
		
		super();
		_font = PxBitmapFont.fetch("default");
	}
	
	/**
	 * Clears all resources used.
	 */
	override public function dispose():Void 
	{
		_font = null;
		super.dispose();
	}
	
	/**
	 * Sets which text to display.
	 * @param pText	Text to display.
	 */
	public var text(null, set_text):String;
	
	public function set_text(pText:String):String 
	{
		_text = pText;
		_text = _text.split("\\n").join("\n");
		_pendingTextChange = true;
		return _text;
	}
	
	private function updateBitmapData():Void 
	{
		if (_font == null)
		{
			return;
		}
		if (_text == "")
		{
			return;
		}
		
		var calcFieldWidth:Int = _fieldWidth;
		var rows:Array<String> = [];
		var fontHeight:Int;
		var alignment:Int = _alignment;
		
		fontHeight = _font.getFontHeight();
		
		// cut text into pices
		var lineComplete:Bool;
		
		// get words
		var lines:Array<String> = _text.split("\n");
		var i:Int = -1;
		while (++i < lines.length) 
		{
			lineComplete = false;
			var words:Array<String> = lines[i].split(" ");
			if (words.length > 0) 
			{
				var wordPos:Int = 0;
				var txt:String = "";
				while (!lineComplete) 
				{
					var changed:Bool = false;
					
					var currentRow:String = txt + words[wordPos] + " ";
					
					if (_multiLine) 
					{
						if (_font.getTextWidth(currentRow) > _fieldWidth) 
						{
							//rows.push(txt.substring(0, txt.length - 1));
							rows.push(txt.substr(0, txt.length - 1));
							txt = "";
							changed = true;
						}
					}
					
					txt += words[wordPos] + " ";
					wordPos++;
					
					if (wordPos >= words.length) 
					{
						if (!changed) 
						{
							//var subText:String = txt.substring(0, txt.length - 1);
							var subText:String = txt.substr(0, txt.length - 1);
							calcFieldWidth = Math.floor(Math.max(calcFieldWidth, _font.getTextWidth(subText)));
							rows.push( subText );
						}
						lineComplete = true;
					}
				}
			}
		}
		
		var finalWidth:Int = calcFieldWidth + _padding * 2 + (_outline ? 2 : 0);
		var finalHeight:Int = Math.floor(_padding * 2 + Math.max(1, rows.length * fontHeight + (_shadow ? 1 : 0)) + (_outline ? 2 : 0));
		
		if (bitmapData != null) 
		{
			if (finalWidth != bitmapData.width || finalHeight != bitmapData.height) 
			{
				bitmapData.dispose();
				bitmapData = null;
			}
		}
		
		if (bitmapData == null) 
		{
			bitmapData = new BitmapData(finalWidth, finalHeight, !_background, _backgroundColor);
		} 
		else 
		{
			bitmapData.fillRect(bitmapData.rect, _backgroundColor);
		}
		
		// render text
		var row:Int = 0;
		bitmapData.lock();
		for (t in rows) 
		{
			var ox:Int = 0; // LEFT
			var oy:Int = 0;
			if (alignment == Pixelizer.CENTER) 
			{
				ox = Math.floor((_fieldWidth - _font.getTextWidth(t) / 2) - _fieldWidth / 2);
			}
			if (alignment == Pixelizer.RIGHT) 
			{
				ox = _fieldWidth - _font.getTextWidth(t);
			}
			if (_outline) 
			{
				for (py in 0...(2 + 1)) 
				{
					for (px in 0...(2 + 1)) 
					{
						_font.render(bitmapData, t, _outlineColor, px + ox + _padding, py + row * fontHeight + _padding);
					}
				}
				ox += 1;
				oy += 1;
			}
			if (_shadow) 
			{
				_font.render(bitmapData, t, _shadowColor, 1 + ox + _padding, 1 + oy + row * fontHeight + _padding);
			}
			_font.render(bitmapData, t, _color, ox + _padding, oy + row * fontHeight + _padding);
			row++;
		}
		bitmapData.unlock();
		
		_pendingTextChange = false;
	}
	
	/**
	 * Updates the bitmap data for the text field if any changes has been made.
	 * @param	pDT
	 */
	override public function update(pDT:Float):Void 
	{
		super.update(pDT);
		
		if (_pendingTextChange) 
		{
			updateBitmapData();
		}
	}
	
	/**
	 * Specifies whether the text field should have a filled background.
	 */
	
	public var background(null, set_background):Bool;
	
	public function set_background(value:Bool):Bool 
	{
		_background = value;
		_pendingTextChange = true;
		return value;
	}
	
	/**
	 * Specifies the color of the text field background.
	 */
	
	public var backgroundColor(null, set_backgroundColor):Int;
	
	public function set_backgroundColor(value:Int):Int
	{
		_backgroundColor = value;
		_pendingTextChange = true;
		return value;
	}
	
	/**
	 * Specifies whether the text should have a shadow.
	 */
	
	public var shadow(null, set_shadow):Bool;
	
	public function set_shadow(value:Bool):Bool
	{
		_shadow = value;
		
		if (_shadow) 
		{
			_outline = false;
		}
		
		_pendingTextChange = true;
		return value;
	}
	
	/**
	 * Specifies the color of the text field shadow.
	 */
	
	public var shadowColor(null, set_shadowColor):Int;
	
	public function set_shadowColor(value:Int):Int 
	{
		_shadowColor = value;
		_pendingTextChange = true;
		return value;
	}
	
	/**
	 * Sets the padding of the text field. This is the distance between the text and the border of the background (if any).
	 */
	
	public var padding(null, set_padding):Int;
	
	public function set_padding(value:Int):Int 
	{
		_padding = value;
		_pendingTextChange = true;
		return value;
	}
	
	/**
	 * Sets the color of the text.
	 */
	
	public var color(null, set_color):Int;
	
	public function set_color(value:Int):Int 
	{
		_color = value;
		_pendingTextChange = true;
		return value;
	}
	
	/**
	 * Sets the width of the text field. If the text does not fit, it will spread on multiple lines.
	 */
	
	public var width(null, set_width):Int;
	
	public function set_width(pWidth:Int):Int 
	{
		_fieldWidth = pWidth;
		if (_fieldWidth < 1) 
		{
			_fieldWidth = 1;
		}
		_pendingTextChange = true;
		return pWidth;
	}
	
	/**
	 * Specifies how the text field should align text.
	 * LEFT, RIGHT, CENTER.
	 */
	
	public var alignment(null, set_alignment):Int;
	
	public function set_alignment(pAlignment:Int):Int 
	{
		_alignment = pAlignment;
		_pendingTextChange = true;
		return pAlignment;
	}
	
	/**
	 * Specifies whether the text field will break into multiple lines or not on overflow.
	 */
	
	public var multiLine(null, set_multiLine):Bool;
	
	public function set_multiLine(pMultiLine:Bool):Bool 
	{
		_multiLine = pMultiLine;
		_pendingTextChange = true;
		return pMultiLine;
	}
	
	/**
	 * Specifies whether the text should have an outline.
	 */
	
	public var outline(null, set_outline):Bool;
	
	public function set_outline(value:Bool):Bool 
	{
		_outline = value;
		if (_outline) 
		{
			_shadow = false;
		}
		_pendingTextChange = true;
		return value;
	}
	
	/**
	 * Specifies whether color of the text outline.
	 */
	
	public var outlineColor(null, set_outlineColor):Int;
	
	public function set_outlineColor(value:Int):Int 
	{
		_outlineColor = value;
		_pendingTextChange = true;
		return value;
	}
	
	/**
	 * Sets which font to use for rendering.
	 */
	
	public var font(null, set_font):PxBitmapFont;
	
	public function set_font(pFont:PxBitmapFont):PxBitmapFont 
	{
		_font = pFont;
		_pendingTextChange = true;
		return pFont;
	}

}