package examples.collision;

import flash.display.Bitmap;
import flash.display.BitmapData;
import pixelizer.components.collision.PxGridColliderComponent;
import pixelizer.components.PxBodyComponent;
import pixelizer.components.render.PxTileMapComponent;
import pixelizer.Pixelizer;
import pixelizer.PxEntity;
import pixelizer.PxInput;
import pixelizer.PxScene;
import pixelizer.render.PxSpriteSheet;
import pixelizer.utils.PxImageUtil;
import pixelizer.utils.PxMath;

class CollisionExampleScene extends PxScene 
{
	
	private var _controllableEntity:PxEntity;
	
	public function new() 
	{
		super();
		
		// bg color of scene
		backgroundColor = Pixelizer.COLOR_WHITE;
		
		var bd:BitmapData = PxImageUtil.createRect(32, 16, Pixelizer.COLOR_RED);
		var spriteSheet:PxSpriteSheet = new PxSpriteSheet();
		spriteSheet.addFramesFromBitmapData(bd, 16, 16);
		bd.dispose();
		
		var tc:PxTileMapComponent = new PxTileMapComponent(7, 7, spriteSheet);
		tc.setTile(2, 2, 1);
		tc.setTile(2, 3, 1);
		tc.setTile(3, 3, 1);
		tc.setTile(4, 3, 1);
		tc.setTile(5, 3, 1);
		tc.setTile(5, 4, 1);
		tc.setTile(3, 6, 1);
		var gc:PxGridColliderComponent = new PxGridColliderComponent(7, 7, 16);
		gc.setCell(2, 2, 1);
		gc.setCell(2, 3, 1);
		gc.setCell(3, 3, 1);
		gc.setCell(4, 3, 1);
		gc.setCell(5, 3, 1);
		gc.setCell(5, 4, 1);
		gc.setCell(3, 6, 1);
		
		var tiles:PxEntity = addEntity(new PxEntity(40, 40));
		tiles.addComponent(tc);
		tiles.addComponent(gc);
		
		_controllableEntity = addEntity(new VisualCollisionEntity(true));
		_controllableEntity.transform.setPosition(160, 120);
		
		// some things to collide with
		for (i in 0...40) 
		{
			var e:VisualCollisionEntity = new VisualCollisionEntity(PxMath.randomBoolean());
			e.transform.setPosition(PxMath.randomInt(40, 264), PxMath.randomInt(40, 184));
			addEntity(e);
		}
	
	}
	
	override public function update(pDT:Float):Void 
	{
		var vx:Float = 4 * PxMath.sign(Math.floor(PxInput.mouseX / 16) - Math.floor(_controllableEntity.transform.position.x / 16));
		var vy:Float = 4 * PxMath.sign(Math.floor(PxInput.mouseY / 16) - Math.floor(_controllableEntity.transform.position.y / 16));
		cast(_controllableEntity.getComponentByClass(PxBodyComponent), PxBodyComponent).setVelocity(vx, vy);
		
		super.update(pDT);
		
		if (PxInput.isPressed(PxInput.KEY_ESC)) 
		{
			engine.popScene();
		}
	}

}