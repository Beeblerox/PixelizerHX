package examples.platformer;

import examples.ExampleLauncher;
import nme.geom.Point;
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
import pixelizer.utils.PxMath;
import pixelizer.utils.PxRepository;

/**
 * ...
 * @author Johan Peitz
 */
class GoodPickup extends PxActorEntity 
{
	
	public function new() 
	{
		super();
		
		animComp.spriteSheet = PxRepository.fetch("pickups");
		animComp.gotoAndPlay("good");
		
		// the body handles velocities 
		bodyComp.mass = 0;
		
		boxColliderComp.setSize(16, 16);
		boxColliderComp.solid = false;
		boxColliderComp.addToCollisionLayer(1);// pick ups
		boxColliderComp.registerCallbacks(onCollisionStart);
	}
	
	override public function dispose():Void 
	{
		super.dispose();
	}
	
	override public function update(pDT:Float):Void 
	{
		bodyComp.velocity.x *= 0.9;
		bodyComp.velocity.y *= 0.9;
		
		super.update(pDT);
	}
	
	// collided with player
	private function onCollisionStart(pCollisionData:PxCollisionData):Void 
	{
		var dist:Float;
		var f:Float;
		var a:Float;
		var colors:Array<Int> = [ 0xFF5750, 0xCC2E29, 0xFFA9A6, 0xFFFFFF ];
		
		PxSoundManager.play(Assets.getSound("assets/heart" + ExampleLauncher.Sound_Format), transform.position);
		
		// emit particles
		for (i in 0...50) 
		{
			var p:ExplosionParticle = new ExplosionParticle(0.7 + Math.random() * 0.4, colors[Math.floor(Math.random() * 4) ]);
			p.transform.position.x = transform.position.x;
			p.transform.position.y = transform.position.y;
			parent.addEntity(p);
		}
		
		// push away bad pickups
		var bads:Array<PxEntity> = new Array<PxEntity>();
		scene.getEntitesByClass(scene.entityRoot, BadPickup, bads);
		for (b in bads) 
		{
			dist = Point.distance(b.transform.position, transform.position);
			if (dist < 150) 
			{
				a = Math.atan2(b.transform.position.y - transform.position.y, b.transform.position.x - transform.position.x);
				f = 10000 / (dist * dist);
				cast(b, BadPickup).addVelocity(f * PxMath.cos(a), f * Math.sin(a));
			}
		}
		
		// attract good pickups
		var goods:Array<PxEntity> = new Array<PxEntity>();
		scene.getEntitesByClass(scene.entityRoot, GoodPickup, goods);
		for (g in goods) 
		{
			dist = Point.distance(g.transform.position, transform.position);
			
			a = Math.atan2(g.transform.position.y - transform.position.y, g.transform.position.x - transform.position.x);
			f = 10000 / (dist * dist);
			cast(g, GoodPickup).addVelocity(-f * PxMath.cos(a), -f * Math.sin(a));
		}
		
		destroyIn(0);
	}
	
	public function addVelocity(pVX:Float, pVY:Float):Void 
	{
		bodyComp.velocity.x += pVX;
		bodyComp.velocity.y += pVY;
	}

}