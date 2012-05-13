package examples.platformer;

import examples.ExampleLauncher;
import nme.Assets;
import pixelizer.components.collision.PxBoxColliderComponent;
import pixelizer.components.PxBodyComponent;
import pixelizer.components.render.PxAnimationComponent;
import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.physics.PxCollisionData;
import pixelizer.prefabs.PxActorEntity;
import pixelizer.PxEntity;
import pixelizer.render.PxSpriteSheet;
import pixelizer.sound.PxSoundManager;
import pixelizer.utils.PxRepository;

/**
 * ...
 * @author Johan Peitz
 */
class BadPickup extends PxActorEntity 
{
	
	public function new() 
	{
		super();
		
		// anim comp, to handle animations
		animComp.spriteSheet = PxRepository.fetch("pickups");
		animComp.gotoAndPlay("bad");
		
		bodyComp.mass = 0;
		
		boxColliderComp.setSize(16, 16);
		boxColliderComp.solid = true;
		boxColliderComp.addToCollisionLayer(1); // pickups
		boxColliderComp.registerCallbacks(onCollisionStart);
	
	}
	
	override public function dispose():Void 
	{
		super.dispose();
	}
	
	public function addVelocity(pVX:Float, pVY:Float):Void 
	{
		bodyComp.velocity.x += pVX;
		bodyComp.velocity.y += pVY;
	}
	
	override public function update(pDT:Float):Void 
	{
		bodyComp.velocity.x *= 0.95;
		bodyComp.velocity.y *= 0.95;
		
		// explode if outside map
		if (transform.position.x < 0 || transform.position.x > 624 || transform.position.y < 0 || transform.position.y > 224) 
		{
			explode();
		}
		
		super.update(pDT);
	}
	
	// player has collided with entity
	private function onCollisionStart(pCollisionData:PxCollisionData):Void 
	{
		explode();
	}
	
	// launch particles and destroy self
	private function explode():Void 
	{
		var colors:Array<Int> = [0x211421, 0x463947, 0x736973, 0x0];
		// emit particles
		for (i in 0...50) 
		{
			var p:ExplosionParticle = new ExplosionParticle(0.7 + Math.random() * 0.4, colors[Math.floor(Math.random() * 4)]);
			p.transform.position.x = transform.position.x;
			p.transform.position.y = transform.position.y;
			parent.addEntity(p);
		}
		
		PxSoundManager.play(Assets.getSound("assets/explosion" + ExampleLauncher.Sound_Format), transform.position);
		destroyIn(0);
	}

}