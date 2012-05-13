package pixelizer.render;

import nme.display.BitmapData;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import pixelizer.utils.PxLog;

/**
 * Holds information and bitmap glpyhs for a bitmap font.
 * @author Johan Peitz
 */
class PxBitmapFont 
{
	private static var ZERO_POINT:Point = new Point();
	
	private var _glyphs:Array<BitmapData>;
	private var _glyphString:String;
	private var _maxHeight:Int;
	
	private var _matrix:Matrix;
	private var _colorTransform:ColorTransform;
	private var _point:Point;
	
	/**
	 * Creates a new bitmap font using specified bitmap data and letter input.
	 * @param	pBitmapData	The bitmap data to copy letters from.
	 * @param	pLetters	String of letters available in the bitmap data.
	 */
	public function new(pBitmapData:BitmapData, pLetters:String) 
	{
		_maxHeight = 0;
		_matrix = new Matrix();
		_colorTransform = new ColorTransform();
		_point = new Point();
		
		_glyphs = [];
		_glyphString = pLetters;
		
		// fill array with nulls
		for (i in 0...(256)) 
		{
			_glyphs.push(null);
		}
		
		if (pBitmapData != null) 
		{
			// get glyphs from bitmap
			var bgColor:Int = pBitmapData.getPixel(0, 0);
			var letterID:Int = 0;
			var cy:Int = 0;
			var cx:Int;
			//for (cy in 0...(pBitmapData.height)) 
			while (cy < pBitmapData.height)
			{
				var rowHeight:Int = 0;
				cx = 0;
				//for (cx in 0...(pBitmapData.width)) 
				while (cx < pBitmapData.width)
				{
					if (Std.int(pBitmapData.getPixel(cx, cy)) != bgColor) 
					{
						// found non bg pixel
						var gx:Int = cx;
						var gy:Int = cy;
						// find width and height of glyph
						while (Std.int(pBitmapData.getPixel(gx, cy)) != bgColor)
						{
							gx++;
						}
						while (Std.int(pBitmapData.getPixel(cx, gy)) != bgColor)
						{
							gy++;
						}
						var gw:Int = gx - cx;
						var gh:Int = gy - cy;
						
						// create glyph
						var bd:BitmapData = new BitmapData(gw, gh, true, 0x0);
						bd.copyPixels(pBitmapData, new Rectangle(cx, cy, gw, gh), ZERO_POINT, null, null, true);
						
						// store glyph
						setGlyph(_glyphString.charCodeAt(letterID), bd);
						letterID++;
						
						// store max size
						if (gh > rowHeight) 
						{
							rowHeight = gh;
						}
						if (gh > _maxHeight) 
						{
							_maxHeight = gh;
						}
						
						// go to next glyph
						cx += gw;
					}
					
					cx++;
				}
				// next row
				//cy += rowHeight;
				cy += (rowHeight + 1);
			}
		}
	
	}
	
	/**
	 * Clears all resources used by the font.
	 */
	public function dispose():Void 
	{
		var bd:BitmapData;
		for (i in 0...(_glyphs.length)) 
		{
			bd = _glyphs[i];
			if (bd != null) 
			{
				_glyphs[i].dispose();
			}
		}
		_glyphs = null;
	}
	
	/**
	 * Serializes font data to cryptic bit string.
	 * @return	Cryptic string with font as bits.
	 */
	public function getFontData():String 
	{
		var output:String = "";
		for (i in 0...(_glyphString.length)) 
		{
			var charCode:Int = _glyphString.charCodeAt(i);
			var glyph:BitmapData = _glyphs[charCode];
			output += _glyphString.substr(i, 1);
			output += glyph.width;
			output += glyph.height;
			for (py in 0...(glyph.height)) 
			{
				for (px in 0...(glyph.width)) 
				{
					output += (glyph.getPixel32(px, py) != 0 ? "1":"0");
				}
			}
		}
		return output;
	}
	
	private function setGlyph(pCharID:Int, pBitmapData:BitmapData):Void 
	{
		if (_glyphs[pCharID] != null) 
		{
			_glyphs[pCharID].dispose();
		}
		
		_glyphs[pCharID] = pBitmapData;
		
		if (pBitmapData.height > _maxHeight) 
		{
			_maxHeight = pBitmapData.height;
		}
	}
	
	/**
	 * Renders a string of text onto bitmap data using the font.
	 * @param	pBitmapData	Where to render the text.
	 * @param	pText	Test to render.
	 * @param	pColor	Color of text to render.
	 * @param	pOffsetX	X position of thext output.
	 * @param	pOffsetY	Y position of thext output.
	 */
	#if flash
	public function render(pBitmapData:BitmapData, pText:String, pColor:UInt, pOffsetX:Int, pOffsetY:Int):Void 
	#else
	public function render(pBitmapData:BitmapData, pText:String, pColor:Int, pOffsetX:Int, pOffsetY:Int):Void 
	#end
	{
		_point.x = pOffsetX;
		_point.y = pOffsetY;
		var glyph:BitmapData;
		
		for (i in 0...(pText.length)) 
		{
			var charCode:Int = pText.charCodeAt(i);
			glyph = _glyphs[charCode];
			if (glyph != null) 
			{
				_matrix.identity();
				_matrix.translate(_point.x, _point.y);
				#if flash
				_colorTransform.color = pColor;
				#else
				_colorTransform.redOffset = pColor >> 16 & 0xFF;
				_colorTransform.greenOffset = pColor >> 8 & 0xFF;
				_colorTransform.blueOffset = pColor & 0xFF;
				_colorTransform.redMultiplier = _colorTransform.greenMultiplier = _colorTransform.blueMultiplier = 0;
				#end
				pBitmapData.draw(glyph, _matrix, _colorTransform);
				_point.x += glyph.width;
			}
		}
	}
	
	/**
	 * Returns the width of a certain test string.
	 * @param	pText	String to measure.
	 * @return	Width in pixels.
	 */
	public function getTextWidth(pText:String):Int 
	{
		var w:Int = 0;
		
		for (i in 0...(pText.length)) 
		{
			var charCode:Int = pText.charCodeAt(i);
			var glyph:BitmapData = _glyphs[charCode];
			if (glyph != null) 
			{
				w += glyph.width;
			}
		}
		
		return w;
	}
	
	/**
	 * Returns height of font in pixels.
	 * @return Height of font in pixels.
	 */
	public function getFontHeight():Int 
	{
		return _maxHeight;
	}
	
	/**
	 * Returns number of letters available in this font.
	 * @return Number of letters available in this font.
	 */
	
	public var numLetters(get_numLetters, null):Int;
	
	public function get_numLetters():Int 
	{
		return _glyphs.length;
	}

}