package pixelizer.components.render;

import nme.geom.Point;
import nme.Lib;
import pixelizer.components.PxComponent;
import pixelizer.PxEntity;
import pixelizer.render.PxAnimation;
import pixelizer.render.PxSpriteSheet;

/**
 * Handles animation of a blit render component using sprite sheets.
 * @author Johan Peitz
 */
class PxAnimationComponent extends PxComponent 
{
	private var _spriteSheet:PxSpriteSheet;
	private var _renderComponentRef:PxBlitRenderComponent;
	private var _currentAnimation:PxAnimation;
	private var _currentAnimationFrame:Int;
	private var _currentSpriteSheetFrame:Int;
	private var _animationPlaying:Bool;
	private var _frameTimer:Float;
	private var _frameDuration:Float;
	
	private var _flipFlags:Int;
	private var _lastFlipFlags:Int;
	private var _currentAnimationLabel:String;
	private var _renderComponentNeedsUpdate:Bool;
	
	/**
	 * Creates a new component.
	 * @param	pSpriteSheet	Sprite sheet to use.
	 */
	public function new(?pSpriteSheet:PxSpriteSheet = null) 
	{
		_animationPlaying = false;
		_frameDuration = 0.1;
		_flipFlags = 0;
		_lastFlipFlags = 0;
		_renderComponentNeedsUpdate = false;
		
		super();
		_spriteSheet = pSpriteSheet;
	}
	
	/**
	 * Clears all resources used by component.
	 */
	override public function dispose():Void 
	{
		super.dispose();
		
		_spriteSheet = null;
		_renderComponentRef = null;
	}
	
	/**
	 * Invoked when added to an entity. Acquires link to entitie's render component.
	 * @param	pEntity	Entity added to.
	 */
	override public function onAddedToEntity(pEntity:PxEntity):Void 
	{
		super.onAddedToEntity(pEntity);
		_renderComponentRef = cast(entity.getComponentByClass(PxBlitRenderComponent), PxBlitRenderComponent);
	}
	
	/**
	 * Stops any playing animation.
	 */
	public function stop():Void 
	{
		_animationPlaying = false;
	}
	
	/**
	 * Sets a specific frame and stops.
	 * @param	pFrame
	 */
	public function gotoAndStop(pFrame:Int):Void 
	{
		_animationPlaying = false;
		_currentSpriteSheetFrame = pFrame;
		_renderComponentNeedsUpdate = true;
	}
	
	/**
	 * Starts an animation.
	 * @param	pLabel	Animation to start.
	 * @param	pRestart	Specifies whether to restart the animation if it is already playing.
	 */
	public function gotoAndPlay(pLabel:String, pRestart:Bool = true):Void 
	{
		if (!pRestart && _currentAnimationLabel == pLabel && _flipFlags == _lastFlipFlags)
		{
			return;
		}
		
		_currentAnimation = _spriteSheet.getAnimation(pLabel);
		if (_currentAnimation != null) 
		{
			_currentAnimationLabel = pLabel;
			
			_currentAnimationFrame = 0;
			_animationPlaying = true;
			_frameTimer = 0;
			_frameDuration = 1 / _currentAnimation.fps;
		}
		
		// show first frame
		_currentSpriteSheetFrame = _currentAnimation.frames[_currentAnimationFrame];
		_renderComponentNeedsUpdate = true;
	}
	
	/**
	 * Updates which frame to show depending on animation data.
	 * Invoked regularly by the entity.
	 * @param	pDT	Time step.
	 */
	override public function update(pDT:Float):Void 
	{
		super.update(pDT);
		
		if (_animationPlaying) 
		{
			_frameTimer += pDT;
			
			if (_frameTimer > _frameDuration) 
			{
				_frameTimer -= _frameDuration;
				_currentAnimationFrame++;
				if (_currentAnimationFrame >= _currentAnimation.frames.length) 
				{
					switch (_currentAnimation.onComplete) 
					{
						case PxAnimation.ANIM_LOOP: 
							_currentAnimationFrame = 0;
						
						case PxAnimation.ANIM_STOP: 
							_animationPlaying = false;
							_currentAnimationFrame--; // stay on last frame
						
						case PxAnimation.ANIM_GOTO: 
							gotoAndPlay(_currentAnimation.gotoLabel);
					}
				}
				
				_currentSpriteSheetFrame = _currentAnimation.frames[_currentAnimationFrame];
				_renderComponentNeedsUpdate = true;
			}
		}
		
		if (_renderComponentNeedsUpdate) 
		{
			updateRenderComponent();
		}
		
		_lastFlipFlags = _flipFlags;
	}
	
	public var spriteSheet(get_spriteSheet, set_spriteSheet):PxSpriteSheet;
	
	/**
	 * Sets which sprite sheet to use.
	 */
	public function set_spriteSheet(pSpriteSheet:PxSpriteSheet):PxSpriteSheet 
	{
		_spriteSheet = pSpriteSheet;
		_currentSpriteSheetFrame = 0;
		_renderComponentNeedsUpdate = true;
		return pSpriteSheet;
	}
	
	/**
	 * Returns which sprite sheet that is currently used.
	 * @return Current sprite sheet.
	 */
	public function get_spriteSheet():PxSpriteSheet 
	{
		return _spriteSheet;
	}
	
	/**
	 * Sets whether to use flipped frames or not.
	 */
	
	public var flip(null, set_flip):Int;
	
	public function set_flip(pFlipFlags:Int):Int 
	{
		_lastFlipFlags = _flipFlags;
		_flipFlags = pFlipFlags;
		if (_lastFlipFlags != pFlipFlags) 
		{
			_renderComponentNeedsUpdate = true;
		}
		return pFlipFlags;
	}
	
	private function updateRenderComponent():Void 
	{
		if (_renderComponentRef != null) 
		{
			_renderComponentRef.bitmapData = _spriteSheet.getFrame(_currentSpriteSheetFrame, _flipFlags);
			if (_renderComponentRef != null) 
			{
				var offset:Point = _spriteSheet.getFrameOffset(_currentSpriteSheetFrame, _flipFlags);
				_renderComponentRef.renderOffset.x = offset.x;
				_renderComponentRef.renderOffset.y = offset.y;
				
				_renderComponentNeedsUpdate = false;
			}
		}
	}
	
	/**
	 * Returns the label of the current animation.
	 * @return Current animation label.
	 */
	
	public var currentLabel(get_currentLabel, null):String;
	
	public function get_currentLabel():String 
	{
		return _currentAnimationLabel;
	}

}