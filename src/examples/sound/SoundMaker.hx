package examples.sound;

//import examples.assets.AssetFactory;
import nme.Assets;
import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.Pixelizer;
import pixelizer.PxEntity;
import pixelizer.utils.PxImageUtil;

/**
 * ...
 * @author Johan Peitz
 */
class SoundMaker extends PxEntity 
{
	private var _timePassed:Float;
	
	public function new() 
	{
		_timePassed = 0;
		super(160, 120);
		addComponent(new PxBlitRenderComponent(PxImageUtil.createRect(32, 32, Pixelizer.COLOR_BLUE)));
		
		addEntity(new VisibleSoundEntity(Assets.getSound("assets/bird_song.mp3"), Pixelizer.ZERO_POINT, true));
	}
	
	override public function update(pDT:Float):Void 
	{
		// rotate for fun
		_timePassed += pDT;
		transform.position.x = 160 + 160 * Math.sin(_timePassed / 2);
		transform.rotation = _timePassed * 4;
		
		super.update(pDT);
	}

}