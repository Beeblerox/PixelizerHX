package pixelizer.render;

import nme.display.BitmapData;
#if (flash || cpp)
import format.swf.MovieClip;
#end
import nme.display.StageQuality;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import pixelizer.Pixelizer;
import pixelizer.utils.PxLog;

/**
 * Holds information and bitmap data for a set of sprites.
 * Sprite sheets are used for both animated sprites and tilemaps.
 * @author Johan Peitz
 */
class PxSpriteSheet 
{
	private var _frameOffsets:Array<Point>;
	private var _framesDefault:Array<BitmapData>;
	private var _framesHFlip:Array<BitmapData>;
	private var _framesVFlip:Array<BitmapData>;
	private var _spriteWidth:Int;
	private var _spriteHeight:Int;
	private var _totalFrames:Int;
	
	private var _animations:Hash<PxAnimation>;
	
	/**
	 * Constructs a new sprite sheet.
	 */
	public function new() 
	{
		_framesDefault = new Array<BitmapData>();
		_frameOffsets = new Array<Point>();
		_framesHFlip = new Array<BitmapData>();
		_framesVFlip = new Array<BitmapData>();
		
		_animations = new Hash<PxAnimation>();
	}
	
	/**
	 * Adds frames to the sheet using bitmap data.
	 * @param	pBitmapData	Bitmap data to copy data from.
	 * @param	pSpriteWidth	Width of each sprite.
	 * @param	pSpriteHeight	Height of each sprite.
	 * @param	pFlipFlags	Specifies whether to store flipped versions of each sprite.
	 * @return Number of frames added.
	 */
	public function addFramesFromBitmapData(pBitmapData:BitmapData, pSpriteWidth:Int, pSpriteHeight:Int, ?pFlipFlags:Int = 0):Int 
	{
		var framesCreated:Int = 0;
		
		_spriteWidth = pSpriteWidth;
		_spriteHeight = pSpriteHeight;
		
		var rect:Rectangle = new Rectangle(0, 0, _spriteWidth, _spriteHeight);
		
		var rows:Int = Math.floor(pBitmapData.height / _spriteHeight);
		var framesPerRow:Int = Math.floor(pBitmapData.width / _spriteWidth);
		var currentFrame:Int = 0;
		while (currentFrame < rows * framesPerRow) 
		{
			rect.x = _spriteWidth * (currentFrame % framesPerRow);
			rect.y = _spriteHeight * Math.floor(currentFrame / framesPerRow);
			var bd:BitmapData = new BitmapData(_spriteWidth, _spriteHeight, true, 0x0);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -rect.x, -rect.y);
			
			bd.draw(pBitmapData, matrix);
			_framesDefault.push(bd);
			_frameOffsets.push(new Point(0, 0));
			
			if ((pFlipFlags & Pixelizer.H_FLIP) != 0) 
			{
				bd = new BitmapData(_spriteWidth, _spriteHeight, true, 0x0);
				matrix = new Matrix(-1, 0, 0, 1, rect.x + _spriteWidth, -rect.y);
				bd.draw(pBitmapData, matrix);
				_framesHFlip.push(bd);
			}
			
			if ((pFlipFlags & Pixelizer.V_FLIP) != 0) 
			{
				bd = new BitmapData(_spriteWidth, _spriteHeight, true, 0x0);
				matrix = new Matrix(1, 0, 0, -1, -rect.x, rect.y + _spriteHeight);
				bd.draw(pBitmapData, matrix);
				_framesVFlip.push(bd);
			}
			
			currentFrame++;
			framesCreated++;
		}
		
		return framesCreated;
	}
	
	/**
	 * Adds frames to the sheet using movieclip frames.
	 * @param pMC	Movieclip to copy data from.
	 * @param pQuality	Quality to use while rendering frames.
	 * @return Number of frames added.
	 */
	#if (flash || cpp)
	public function addFramesFromMovieClip(pMC:MovieClip, ?pQuality:StageQuality = null/*StageQuality.LOW*/, ?pFlipFlags:Int = 0):Int 
	{
		var currentQuality:StageQuality = Pixelizer.stage.quality;
		if (pQuality == null)
		{
			pQuality = StageQuality.LOW;
		}
		Pixelizer.stage.quality = pQuality;
		
		for (f in 1...(pMC.totalFrames + 1)) 
		{
			pMC.gotoAndStop(f);
			
			#if flash
			var bounds:Rectangle = pMC.getBounds(pMC);
			#else
			var bounds:Rectangle = new Rectangle(0, 0, pMC.width, pMC.height);
			#end
			
			var bd:BitmapData = new BitmapData(Math.ceil(bounds.width), Math.ceil(bounds.height), true, 0x0);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y);
			
			bd.draw(pMC, matrix);
			_framesDefault.push(bd);
			_frameOffsets.push(new Point(Math.floor( -bounds.x), Math.floor( -bounds.y)));
			
			if ((pFlipFlags & Pixelizer.H_FLIP) != 0) 
			{
				var bdHFlip:BitmapData = new BitmapData(bd.width, bd.height, true, 0x0);
				matrix = new Matrix(-1, 0, 0, 1, bd.width, 0);
				bdHFlip.draw(bd, matrix);
				_framesHFlip.push(bdHFlip);
			}
		}
		
		// revert quality settings
		Pixelizer.stage.quality = currentQuality;
		
		return pMC.totalFrames;
	}
	#end
	
	/**
	 * Clears all resources used.
	 */
	public function dispose():Void 
	{
		for (bd in _framesDefault) 
		{
			bd.dispose();
		}
		_framesDefault = null;
	}
	
	/**
	 * Adds an animation to this sprite sheet.
	 * @param	pAnimation Animation to store.
	 */
	public function addAnimation(pAnimation:PxAnimation):Void 
	{
		_animations.set(pAnimation.label, pAnimation);
	}
	
	/**
	 * Sets frame offsets for the specified frames.
	 * This is useful if different frames have different hotspots.
	 * @param	pOffsets	Array of objects with offset information.
	 */
	public function setOffsets(pOffsets:Array<Dynamic>):Void 
	{
		for (o in pOffsets) 
		{
			_frameOffsets[o.id].x = o.x;
			_frameOffsets[o.id].y = o.y;
		}
	}
	
	public var spriteHeight(get_spriteHeight, null):Int;
	
	/**
	 * Returns the height of a sprite.
	 * @return Height of sprite.
	 */
	public function get_spriteHeight():Int 
	{
		return _spriteHeight;
	}
	
	public var spriteWidth(get_spriteWidth, null):Int;
	
	/**
	 * Returns the width of a sprite.
	 * @return Width of sprite.
	 */
	public function get_spriteWidth():Int 
	{
		return _spriteWidth;
	}
	
	/**
	 * Returns a specific animation.
	 * @param	pLabel	Label of animation to return.
	 * @return	Found animation, or null.
	 */
	public function getAnimation(pLabel:String):PxAnimation 
	{
		if (_animations.exists(pLabel) == false) 
		{
			PxLog.log("no such label '" + pLabel + "'", this, PxLog.WARNING);
		}
		return _animations.get(pLabel);
	}
	
	/**
	 * Returns the frame offset of a certain frame.
	 * @param	pFrameID	ID of frame to check.
	 * @param	pHFlip	Specifies wether to take into calculation if the sprite is horizontally flipped.
	 * @return	Point with offset data.
	 */
	public function getFrameOffset(pFrameID:Int, pFlipFlags:Int):Point 
	{
		var pt:Point = new Point();
		pt.x = _frameOffsets[pFrameID].x * (((pFlipFlags & Pixelizer.H_FLIP) != 0) ? -1:1);
		pt.y = _frameOffsets[pFrameID].y * (((pFlipFlags & Pixelizer.V_FLIP) != 0) ? -1:1);
		return pt;
	}
	
	/**
	 * Returns the bitmap data for a specific frame.
	 * @param	pFrameID	ID of frame.
	 * @param	pHFlip	Specifies whether frame should be horizontally flipper.
	 * @return	Bitmap data for frame.
	 */
	public function getFrame(pFrameID:Int, pFlipFlags:Int):BitmapData 
	{
		if ((pFlipFlags & Pixelizer.H_FLIP) != 0) 
		{
			return _framesHFlip[pFrameID];
		}
		if ((pFlipFlags & Pixelizer.V_FLIP) != 0) 
		{
			return _framesVFlip[pFrameID];
		}
		
		return _framesDefault[pFrameID];
	}
	
}