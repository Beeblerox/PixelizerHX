package pixelizer.sound;

import nme.events.Event;
import nme.geom.Point;
import nme.media.Sound;
import nme.media.SoundChannel;
import nme.media.SoundTransform;
import pixelizer.PxEntity;
import pixelizer.utils.PxLog;

/**
 * Entity the plays a sound.
 * @author Johan Peitz
 */
class PxSoundEntity extends PxEntity 
{
	private var _sound:Sound;
	private var _soundTransform:SoundTransform;
	private var _soundChannel:SoundChannel;
	
	private var _isLooping:Bool;
	
	private var _isGlobal:Bool;
	
	private var _paused:Bool;
	
	private var _pausePosition:Float;
	
	/**
	 * Constructs a new entity with specified sound.
	 * @param	pSound	Sound to play.
	 * @param	pPosition	Position to play sound at. Pass null for ambient sound.
	 * @param	pLoop	Whether too loop sound or not.
	 */
	public function new(pSound:Sound, ?pPosition:Point = null, ?pLoop:Bool = false) 
	{
		super();
		
		_sound = pSound;
		_isLooping = pLoop;
		_paused = false;
		
		if (pPosition != null) 
		{
			transform.position.x = pPosition.x;
			transform.position.y = pPosition.y;
			_isGlobal = false;
		} 
		else 
		{
			_isGlobal = true;
		}
		
		if (_isGlobal) 
		{
			_soundTransform = new SoundTransform(PxSoundManager.globalVolume);
		} 
		else 
		{
			_soundTransform = new SoundTransform(0, 0);
		}
		
		// start playing the sound
		play();
	}
	
	/**
	 * Disposes entity and stops sound.
	 */
	override public function dispose():Void 
	{
		if (_soundChannel != null) 
		{
			_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			_soundChannel.stop();
			_soundChannel = null;
		}
		
		_sound = null;
		_soundTransform = null;
		
		super.dispose();
	}
	
	private function play(?pPosition:Float = 0):Void 
	{
		_soundChannel = _sound.play(pPosition, 0, _soundTransform);
		if (_soundChannel != null) 
		{
			_soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		} 
		else 
		{
			PxLog.log("out of sound channels, skipping sound '" + _sound + "'", this, PxLog.WARNING);
			destroyIn(0);
		}
	}
	
	/**
	 * Updates the sound and changes it's sound transform depending on position.
	 * @param	pDT
	 */
	override public function update(pDT:Float):Void 
	{
		if (parent != null && !_isGlobal) 
		{
			if (_soundChannel != null) 
			{
				updateSoundTransform(transform.positionOnScene);
				_soundChannel.soundTransform = _soundTransform;
			}
		}
		
		if (_isGlobal)
		{
			setVolumeToGlobalVolume();
		}
		
		super.update(pDT);
	}
	
	/**
	 * Pauses the sound.
	 */
	public function pause():Void 
	{
		if (_paused)
		{
			return;
		}
		if (_soundChannel != null) 
		{
			_paused = true;
			_pausePosition = _soundChannel.position;
			_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			_soundChannel.stop();
			_soundChannel = null;
		}
	}
	
	/**
	 * Resumes the sound.
	 */
	public function unpause():Void 
	{
		if (!_paused)
		{
			return;
		}
		_paused = false;
		play(_pausePosition);
	}
	
	private function updateSoundTransform(pScenePosition:Point):Void 
	{
		var camCenter:Point = scene.camera.center;
		var volDistToCam:Float = Point.distance(pScenePosition, camCenter);
		
		var vol:Float = 1;
		if (volDistToCam > PxSoundManager.volumeRange.x + PxSoundManager.volumeRange.y) 
		{
			vol = 0;
		} 
		else if (volDistToCam > PxSoundManager.volumeRange.x) 
		{
			vol = 1 - (volDistToCam - PxSoundManager.volumeRange.x) / (PxSoundManager.volumeRange.y);
		}
		
		_soundTransform.volume = vol * PxSoundManager.globalVolume;
		
		var panDistToCam:Float = Math.abs(pScenePosition.x - camCenter.x);
		var pan:Float = 0;
		
		if (panDistToCam > PxSoundManager.panRange.x + PxSoundManager.panRange.y) 
		{
			pan = 1;
		} 
		else if (panDistToCam > PxSoundManager.panRange.x) 
		{
			pan = Math.abs(panDistToCam - PxSoundManager.panRange.x) / (PxSoundManager.panRange.y);
		}
		
		if (pScenePosition.x < camCenter.x) 
		{
			pan = -pan;
		}
		
		_soundTransform.pan = pan;
	}
	
	private function onSoundComplete(pEvent:Event):Void 
	{
		_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		if (_isLooping) 
		{
			play();
		} 
		else 
		{
			destroyIn(0);
		}
	}
	
	public function setVolumeToGlobalVolume():Void 
	{
		if (_soundChannel != null) 
		{
			_soundTransform.pan = 0;
			_soundTransform.volume = PxSoundManager.globalVolume;
			_soundChannel.soundTransform = _soundTransform;
		}
	}

}