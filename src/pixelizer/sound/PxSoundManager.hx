package pixelizer.sound;

import nme.geom.Point;
import nme.media.Sound;
import pixelizer.Pixelizer;
import pixelizer.PxEntity;
import pixelizer.utils.PxLog;

/**
 * Manages all global sound issues.
 * @author Johan Peitz
 */
class PxSoundManager 
{
	private static var _storedSounds:Hash<Sound> = new Hash<Sound>();
	
	/**
	 * Sets the distance of where panning starts to occur and for how long until 100% on one end.
	 */
	public static var panRange:Point;
	/**
	 * Sets the distance of where volume starts to drop off how long until 0 left.
	 */
	public static var volumeRange:Point;
	
	/**
	 * Global volume.
	 */
	public static var globalVolume:Float;
	
	/**
	 * Initializes the sound manager. Gets taken care of autmatically.
	 */
	public static function init():Void 
	{
		panRange = new Point(Pixelizer.engine.engineWidth * 0.75 / 2, Pixelizer.engine.engineWidth * 0.75 / 2);
		volumeRange = new Point(Pixelizer.engine.engineWidth / 2, Pixelizer.engine.engineWidth / 2);
		
		globalVolume = 1;
	}
	
	/**
	 * Pauses all sounds.
	 */
	public static function pause():Void 
	{
		var entities:Array<PxEntity> = new Array<PxEntity>();
		Pixelizer.engine.currentScene.getEntitesByClass(Pixelizer.engine.currentScene.entityRoot, PxSoundEntity, entities);
		var pos:Int = entities.length;
		while (--pos >= 0) 
		{
			cast(entities[pos], PxSoundEntity).pause();
		}
	}
	
	/**
	 * Resumes all paused sounds.
	 */
	public static function unpause():Void 
	{
		var entities:Array<PxEntity> = new Array<PxEntity>();
		Pixelizer.engine.currentScene.getEntitesByClass(Pixelizer.engine.currentScene.entityRoot, PxSoundEntity, entities);
		var pos:Int = entities.length;
		while (--pos >= 0) 
		{
			cast(entities[pos], PxSoundEntity).unpause();
		}
	}
	
	/**
	 * Mutes all current and future sounds.
	 */
	public static function mute():Void 
	{
		if (globalVolume > 0) 
		{
			globalVolume = 0;
			
			updateAllSoundEntites();
		}
	}
	
	/**
	 * Unmutes all current and future sounds.
	 */
	public static function unmute():Void 
	{
		if (globalVolume == 0) 
		{
			globalVolume = 1;
			
			updateAllSoundEntites();
		}
	}
	
	static private function updateAllSoundEntites():Void 
	{
		var entities:Array<PxEntity> = new Array<PxEntity>();
		Pixelizer.engine.currentScene.getEntitesByClass(Pixelizer.engine.currentScene.entityRoot, PxSoundEntity, entities);
		var pos:Int = entities.length;
		while (--pos >= 0) 
		{
			entities[pos].update(0);
		}
	}
	
	/**
	 * Returns true if sounds are muted.
	 * @return	True if sounds are muted.
	 */
	public static function isMuted():Bool 
	{
		return globalVolume == 0;
	}
	
	/**
	 * Returns a previously stored Sound object.
	 * @param	pHandle	Text identifier of the Sound object to return.
	 * @return	A Sound object or null if no match was found.
	 */
	public static function fetch(pHandle:String):Sound 
	{
		var sound:Sound = _storedSounds.get(pHandle);
		if (sound == null) 
		{
			PxLog.log("no sound found with handle '" + pHandle + "'", "[o PxSoundManager]", PxLog.WARNING);
			return null;
		}
		
		return sound;
	}
	
	/**
	 * Stores a Sound object for global use.
	 * @param	pHandle	Text identifier to store the sound with.
	 * @param	pSound	Sound object to store.
	 */
	public static function store(pHandle:String, pSound:Sound):Void 
	{
		_storedSounds.set(pHandle, pSound);
		PxLog.log("sound '" + pHandle + "' stored", "[o PxSoundManager]", PxLog.INFO);
	}
	
	/**
	 * Checks whether a handle is already in use.
	 * @param	pHandle	Identifier to check.
	 * @return True of handle is already used.
	 */
	public static function hasSound(pHandle:String):Bool 
	{
		return _storedSounds.exists(pHandle);
	}
	
	/**
	 * Shortcut for quickly playing a sound.
	 * @param	pSound	Sound to play.
	 * @param	pPosition	Where to play it. Pass null for ambient sounds.
	 * @param	pLoop	Whether to loop the sound or not.
	 */
	public static function play(pSound:Sound, ?pPosition:Point = null, ?pLoop:Bool = false):Void 
	{
		Pixelizer.engine.currentScene.addEntity(new PxSoundEntity(pSound, pPosition, pLoop));
	}

}