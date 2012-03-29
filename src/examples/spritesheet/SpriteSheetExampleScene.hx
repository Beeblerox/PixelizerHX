package examples.spritesheet;

//import examples.assets.AssetFactory;
#if (flash || cpp)
import format.swf.MovieClip;
#end
import flash.display.StageQuality;
import nme.Assets;
import pixelizer.components.render.PxAnimationComponent;
import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.components.render.PxTextFieldComponent;
import pixelizer.Pixelizer;
import pixelizer.prefabs.gui.PxTextFieldEntity;
import pixelizer.PxEntity;
import pixelizer.PxInput;
import pixelizer.PxScene;
import pixelizer.render.PxAnimation;
import pixelizer.render.PxSpriteSheet;
import pixelizer.utils.PxMath;

/**
 * ...
 * @author Johan Peitz
 */
class SpriteSheetExampleScene extends PxScene 
{
	private var _animComp:PxAnimationComponent;
	private var _timePassed:Float;
	private var _animID:Int;
	
	public function new() 
	{
		_timePassed = 0;
		_animID = 0;
		super();
		
		var i:Int;
		
		#if (flash || cpp)
		var sheet:PxSpriteSheet = new PxSpriteSheet();
		var numFrames:Int = sheet.addFramesFromMovieClip(cast(new Animation(), MovieClip), StageQuality.HIGH);
		var frames:Array<Int> = [];
		for (i in 0...(numFrames)) 
		{
			frames.push(i);
		}
		sheet.addAnimation(new PxAnimation("loop", frames, 10, PxAnimation.ANIM_LOOP));
		var e:PxEntity = new PxEntity(120, 85);
		e.addComponent(new PxBlitRenderComponent());
		var anim:PxAnimationComponent = new PxAnimationComponent(sheet);
		anim.gotoAndPlay("loop");
		e.addComponent(anim);
		addEntity(e);
		
		sheet = new PxSpriteSheet();
		numFrames = sheet.addFramesFromMovieClip(cast(new Animation(), MovieClip), StageQuality.LOW);
		frames = [];
		for (i in 0...(numFrames)) 
		{
			frames.push(i);
		}
		sheet.addAnimation(new PxAnimation("loop", frames, 10, PxAnimation.ANIM_LOOP));
		e = new PxEntity(200, 85);
		e.addComponent(new PxBlitRenderComponent());
		anim = new PxAnimationComponent(sheet);
		anim.gotoAndPlay("loop");
		e.addComponent(anim);
		addEntity(e);
		#else
		var sheet:PxSpriteSheet;
		var e:PxEntity;
		#end
		
		sheet = new PxSpriteSheet();
		sheet.addFramesFromBitmapData(Assets.getBitmapData("assets/player.png"), 16, 16);
		sheet.addAnimation(new PxAnimation("idle", [ 0 ]));
		sheet.addAnimation(new PxAnimation("run", [ 0, 1 ], 10, PxAnimation.ANIM_LOOP));
		sheet.addAnimation(new PxAnimation("jump", [ 2 ]));
		sheet.addAnimation(new PxAnimation("die", [ 3, 4 ], 10, PxAnimation.ANIM_LOOP));
		e = new PxEntity(90, 160);
		e.addComponent(new PxBlitRenderComponent());
		_animComp = new PxAnimationComponent(sheet);
		_animComp.gotoAndPlay("run");
		e.addComponent(_animComp);
		addEntity(e);
		
		addEntity(new PxTextFieldEntity("Frames from SWF (high quality).         Frames from SWF (low quality).")).transform.setPosition(20, 20);
		addEntity(new PxTextFieldEntity("Frames from image.")).transform.setPosition(20, 120);
	}
	
	override public function dispose():Void 
	{
		_animComp = null;
		super.dispose();
	}
	
	override public function update(pDT:Float):Void 
	{
		_timePassed += pDT;
		if (_timePassed > 1) 
		{
			_timePassed -= 1;
			_animID++;
			if (_animID == 4) 
			{
				_animID = 0;
			}
			switch (_animID) 
			{
				case 0: 
					_animComp.gotoAndPlay("idle");
				case 1: 
					_animComp.gotoAndPlay("run");
				case 2: 
					_animComp.gotoAndPlay("jump");
				case 3: 
					_animComp.gotoAndPlay("die");
			}
		}
		
		if (PxInput.isPressed(PxInput.KEY_ESC)) 
		{
			engine.popScene();
		}
		
		super.update(pDT);
	}

}