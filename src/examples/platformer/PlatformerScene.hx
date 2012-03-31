package examples.platformer;

//import examples.assets.AssetFactory;
import examples.ExampleLauncher;
import flash.geom.Point;
import nme.Assets;
import pixelizer.components.collision.PxBoxColliderComponent;
import pixelizer.components.collision.PxBoxColliderRenderComponent;
import pixelizer.components.render.PxTextFieldComponent;
import pixelizer.Pixelizer;
import pixelizer.prefabs.gui.PxTextFieldEntity;
import pixelizer.PxEngine;
import pixelizer.PxEntity;
import pixelizer.PxInput;
import pixelizer.PxScene;
import pixelizer.render.PxAnimation;
import pixelizer.render.PxBlitRenderer;
import pixelizer.render.PxCamera;
import pixelizer.render.PxSpriteSheet;
import pixelizer.sound.PxSoundEntity;

/**
 * Holds all entities and manages the game.
 *
 * @author Johan Peitz
 */
class PlatformerScene extends PxScene 
{
	// the level xml
	//[Embed(source='../assets/platformer.oel',mimeType="application/octet-stream")]
	//public static const LevelData:Class;
	
	// layers to better control where things are drawn
	private var _bgLayer:PxEntity;
	private var _actionLayer:PxEntity;
	private var _guiLayer:PxEntity;
	
	// player
	private var _player:Player;
	
	public function new() 
	{
		super();
		
		// background color of scene
		backgroundColor = 0xB0C9F5;
		
		// set up main layers
		_bgLayer = entityRoot.addEntity(new PxEntity());
		_actionLayer = entityRoot.addEntity(new PxEntity());
		_guiLayer = entityRoot.addEntity(new PxEntity());
		// stop guilayer from scrolling
		_guiLayer.transform.scrollFactorX = _guiLayer.transform.scrollFactorY = 0;
		
		// set up simple instructions texts
		var instuctions:PxTextFieldEntity = cast(_guiLayer.addEntity(new PxTextFieldEntity("GRAB HEARTS TO PUSH AWAY SKULLS!")), PxTextFieldEntity);
		instuctions.textField.width = 320;
		instuctions.textField.alignment = Pixelizer.CENTER;
		instuctions.transform.position.y = 4;
		
		// create a player, and add it to the action layer
		_player = new Player();
		_player.reset();
		_actionLayer.addEntity(_player);
		
		// each scene has a camera, set it to track the player
		camera.track(_player);
		
		// use the level data to create tilemap (w/ collision) and add to scene
		var textBytes = Assets.getBytes("assets/platformer.oel");
		var XMLString = textBytes.readUTFBytes(textBytes.length);
		var XMLData = Xml.parse(XMLString);
		var tilemap:TileMap = new TileMap(XMLData);
		_bgLayer.addEntity(tilemap);
		
		// clamp camera to not show anything outside the map
		camera.setBounds(new Point(0, 0), new Point(tilemap.width * 16, tilemap.height * 16));
		
		// spawn some initial pickups
		for (i in 0...20) 
		{
			spawnPickup();
		}
		
		// play music
		addEntity(new PxSoundEntity(Assets.getSound("assets/music_loop" + ExampleLauncher.Sound_Format), null, true));
	}
	
	override public function dispose():Void 
	{
		// get rid of all references, Pixelizer will handle the dispose
		_actionLayer = _bgLayer = null;
		_player = null;
		
		super.dispose();
	}
	
	override public function update(pDT:Float):Void 
	{
		if (Math.random() > 0.91) 
		{
			// spawn pickup
			spawnPickup();
		}
		
		// restart player if off screen
		if (_player.transform.position.y > 400) 
		{
			_player.reset();
		}
		
		super.update(pDT);
		
		if (PxInput.isPressed(PxInput.KEY_ESC)) 
		{
			engine.popScene();
		}
		
		if (PxInput.isPressed(PxInput.KEY_D)) 
		{
			forEachEntity(entityRoot, addColliderRenderer);
		}
		if (PxInput.isPressed(PxInput.KEY_E)) 
		{
			forEachEntity(entityRoot, removeColliderRenderer);
		}
	}
	
	private function addColliderRenderer(pEntity:PxEntity):Void 
	{
		if (pEntity.hasComponentByClass(PxBoxColliderComponent))  
		{
			if (!pEntity.hasComponentByClass(PxBoxColliderRenderComponent)) 
			{
				pEntity.addComponent(new PxBoxColliderRenderComponent());
			}
		}
	}
	
	private function removeColliderRenderer(pEntity:PxEntity):Void 
	{
		if (pEntity.hasComponentByClass(PxBoxColliderRenderComponent))  
		{
			pEntity.removeComponent(new PxBoxColliderRenderComponent());
		}
	}
	
	private function spawnPickup():Void 
	{
		var pickup:PxEntity;
		if (Math.random() > 0.5) 
		{
			pickup = new BadPickup();
		}
		else 
		{
			pickup = new GoodPickup();
		}
		
		// get a spot far from the player and place the pickup there
		var foundSpot:Bool = false;
		while (!foundSpot) 
		{
			var px:Float = Math.random() * 624;
			var py:Float = Math.random() * 224;
			var dist:Float = Point.distance(new Point(px, py), _player.transform.position);
			if (dist > 100) 
			{
				foundSpot = true;
				
				pickup.transform.position.x = px;
				pickup.transform.position.y = py;
			}
		}
		_actionLayer.addEntity(pickup);
	}

}