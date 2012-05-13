package examples.platformer;

import examples.ExampleLauncher;
import nme.Assets;
import pixelizer.components.collision.PxBoxColliderComponent;
import pixelizer.components.collision.PxGridColliderComponent;
import pixelizer.components.PxBodyComponent;
import pixelizer.components.render.PxAnimationComponent;
import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.physics.PxCollisionData;
import pixelizer.Pixelizer;
import pixelizer.prefabs.PxActorEntity;
import pixelizer.PxEntity;
import pixelizer.PxInput;
import pixelizer.render.PxBlitRenderer;
import pixelizer.render.PxSpriteSheet;
import pixelizer.sound.PxSoundEntity;
import pixelizer.utils.PxRepository;

/**
 * ...
 * @author Johan Peitz
 */
class Player extends PxActorEntity 
{
	private var _onGround:Bool;
	
	private var _alive:Bool;
	
	public function new() 
	{
		_onGround = false;
		_alive = true;
		super();
		
		// animComponent, to handle sprite sheet animations
		animComp.spriteSheet = PxRepository.fetch("player");
		animComp.gotoAndPlay("idle");
		
		// set up collider
		boxColliderComp.setSize(16, 16);
		boxColliderComp.registerCallbacks(onCollisionStart, onCollisionOngoing, onCollisionEnd);
		
		reset();
	}
	
	override public function dispose():Void 
	{
		super.dispose();
	}
	
	override public function update(pDT:Float):Void 
	{
		bodyComp.velocity.x *= 0.80;
		
		if (_alive) 
		{
			// handle controls
			if (PxInput.isDown(PxInput.KEY_LEFT)) 
			{
				bodyComp.velocity.x -= 1;
				animComp.flip = Pixelizer.H_FLIP;
			}
			if (PxInput.isDown(PxInput.KEY_RIGHT)) 
			{
				bodyComp.velocity.x += 1;
				animComp.flip = 0;
			}
			
			if (_onGround) 
			{
				if (Math.abs(bodyComp.velocity.x) > 1) 
				{
					animComp.gotoAndPlay("walk", false);
				}
				else 
				{
					animComp.gotoAndPlay("idle");
				}
				if (PxInput.isDown(PxInput.KEY_UP)) 
				{
					bodyComp.velocity.y -= 11;
					animComp.gotoAndPlay("jump");
					addEntity(new PxSoundEntity(Assets.getSound("assets/jump" + ExampleLauncher.Sound_Format), Pixelizer.ZERO_POINT));
				}
			}
			
			// kill player if off map
			if (transform.position.y > 240) 
			{
				die();
			}
		}
		
		super.update(pDT);
	}
	
	// make funny animation and lose control
	private function die():Void 
	{
		_alive = false;
		bodyComp.velocity.y = -10;
		animComp.gotoAndPlay("die");
		boxColliderComp.collisionLayerMask = 0;
		boxColliderComp.collisionLayer = 0;
	}
	
	// player collided with something, act on it
	private function onCollisionStart(pCollisionData:PxCollisionData):Void 
	{
		// collided with grid?
		if (Std.is(pCollisionData.otherCollider, PxGridColliderComponent)) 
		{
			if (pCollisionData.overlap.y != 0) 
			{
				_onGround = true;
				animComp.gotoAndPlay("idle");
			}
		} 
		
		// collided with skull?
		else if (Std.is(pCollisionData.otherCollider.entity, BadPickup)) 
		{
			die();
		}
	}
	
	// a collision is still happening
	private function onCollisionOngoing(pCollisionData:PxCollisionData):Void 
	{
		if (Std.is(pCollisionData.otherCollider, PxGridColliderComponent)) 
		{
			if (_onGround) {
				if (pCollisionData.overlap.y == 0) 
				{
					_onGround = false;
				}
			} 
			else if (!_onGround) 
			{
				if (pCollisionData.overlap.y != 0)
				{
					_onGround = true;
				}
			}
		}
	}
	
	// a collision ended
	private function onCollisionEnd(pCollisionData:PxCollisionData):Void 
	{
		if (Std.is(pCollisionData.otherCollider, PxGridColliderComponent)) 
		{
			_onGround = false;
			animComp.gotoAndPlay("jump");
		}
	}
	
	// reset the player character
	public function reset():Void 
	{
		transform.position.x = 120;
		transform.position.y = 32;
		_alive = true;
		_onGround = false;
		bodyComp.velocity.x = bodyComp.velocity.y = 0;
		animComp.gotoAndPlay("idle");
		
		// what to collide with
		boxColliderComp.enableCollisionWithCollisionLayer(1); // pick ups
		boxColliderComp.enableCollisionWithCollisionLayer(Pixelizer.COLLISION_LAYER_GRID); // grid
	}

}