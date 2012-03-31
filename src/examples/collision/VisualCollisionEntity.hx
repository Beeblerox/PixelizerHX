package examples.collision;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import pixelizer.components.collision.PxBoxColliderComponent;
import pixelizer.components.PxBodyComponent;
import pixelizer.components.render.PxAnimationComponent;
import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.physics.PxCollisionData;
import pixelizer.Pixelizer;
import pixelizer.PxEntity;
import pixelizer.render.PxSpriteSheet;
import pixelizer.utils.PxImageUtil;
import pixelizer.utils.PxMath;

class VisualCollisionEntity extends PxEntity 
{
	private var _rendComp:PxBlitRenderComponent;
	private var _animComp:PxAnimationComponent;
	
	public function new(pSolid:Bool) 
	{
		super();
		
		var frames:BitmapData = PxImageUtil.createRect(32, 16, (pSolid ? 0x338833:0x333388));
		frames.fillRect(new Rectangle(0, 0, 16, 16), (pSolid ? Pixelizer.COLOR_GREEN:Pixelizer.COLOR_BLUE));
		var spriteSheet:PxSpriteSheet = new PxSpriteSheet();
		spriteSheet.addFramesFromBitmapData(frames, 16, 16);
		
		_rendComp = cast(addComponent(new PxBlitRenderComponent()), PxBlitRenderComponent);
		_rendComp.alpha = 0.7;
		_animComp = cast(addComponent(new PxAnimationComponent(spriteSheet)), PxAnimationComponent);
		_animComp.gotoAndStop(0);
		
		addComponent(new PxBodyComponent(0));
		
		var collider:PxBoxColliderComponent = new PxBoxColliderComponent(16, 16, pSolid);
		collider.registerCallbacks(onCollisionStart, onCollisionOngoing, onCollisionEnd);
		addComponent(collider);
	}
	
	override public function dispose():Void 
	{
		_animComp = null;
		super.dispose();
	}
	
	private function onCollisionStart(pCollisionData:PxCollisionData):Void 
	{
		_animComp.gotoAndStop(1);
	}
	
	private function onCollisionOngoing(pCollisionData:PxCollisionData):Void 
	{
		_animComp.gotoAndStop(1);
	}
	
	private function onCollisionEnd(pCollisionData:PxCollisionData):Void 
	{
		_animComp.gotoAndStop(0);
	}
}