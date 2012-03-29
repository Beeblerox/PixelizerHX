package pixelizer;

import nme.display.Stage;
import nme.display.StageQuality;
import nme.display.StageScaleMode;
import nme.geom.Matrix;
import nme.geom.Point;
#if flash
import flash.net.LocalConnection;
#end
import nme.system.System;
import pixelizer.render.PxDefaultFontGenerator;
import pixelizer.sound.PxSoundManager;
import pixelizer.utils.PxLog;
import pixelizer.utils.PxObjectPool;

/**
 * Omnipotent class that can be used to take various short cuts. Also holds various useful things.
 */
class Pixelizer 
{
	public static inline var MAJOR_VERSION:Int = 0;
	public static inline var MINOR_VERSION:Int = 3;
	public static inline var INTERNAL_VERSION:Int = 0;
	
	public static inline var COLOR_RED:Int = 0xFF5D5D;
	public static inline var COLOR_GREEN:Int = 0x5DFC5D;
	public static inline var COLOR_BLUE:Int = 0x5CBCFC;
	public static inline var COLOR_WHITE:Int = 0xFFFFFF;
	public static inline var COLOR_BLACK:Int = 0x000000;
	public static inline var COLOR_GRAY:Int = 0xE6E6E6;
	
	public static inline var LEFT:Int = 1;
	public static inline var RIGHT:Int = 2;
	public static inline var CENTER:Int = 3;
	
	static public inline var H_FLIP:Int = 1;
	static public inline var V_FLIP:Int = 2;
	
	/**
	 * Object pool for points.
	 * Fetch and recycle Points here for added performance.
	 */
	public static var matrixPool:PxObjectPool;
	public static var pointPool:PxObjectPool;
	public static var ZERO_POINT:Point;
	
	/**
	 * Reference to the engine.
	 */
	public static var engine:PxEngine;
	/**
	 * Reference to the stage.
	 */
	public static var stage:Stage;
	
	private static var _isInitialized:Bool = false;
	
	/**
	 * Initializes Pixelizer. Is done automatically when inheriting PxEngine.
	 *
	 * @param	pEngine	Engine which initializes Pixelizer.
	 * @param	pStage	Reference to Flash's stage.
	 */
	public static function init():Void 
	{
		if (_isInitialized) 
		{
			PxLog.log("Pixelizer already initialized.", "[o Pixelizer]", PxLog.WARNING);
			return;
		}
		PxLog.log("", "[o Pixelizer]", PxLog.INFO);
		PxLog.log("*** PIXELIZER v " + MAJOR_VERSION + "." + MINOR_VERSION + "." + INTERNAL_VERSION + " ***", "[o Pixelizer]", PxLog.INFO);
		PxLog.log("", "[o Pixelizer]", PxLog.INFO);
		
		matrixPool = new PxObjectPool(Matrix);
		pointPool = new PxObjectPool(Point);
		ZERO_POINT = pointPool.fetch();
		ZERO_POINT.x = ZERO_POINT.y = 0;
		
		PxDefaultFontGenerator.generateAndStoreDefaultFont();
		
		_isInitialized = true;
	}
	
	static public function onEngineAddedToStage(pEngine:PxEngine, pStage:Stage):Void 
	{
		engine = pEngine;
		stage = pStage;
		
		stage.stageFocusRect = false;
		stage.quality = StageQuality.LOW;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		PxInput.init(stage);
		PxSoundManager.init();
	
	}
	
	/**
	 * Tries to run the garbage collector in all possible ways. May still not work, but most of the time it does.
	 */
	public static function garbageCollect():Void 
	{
		#if flash
		System.gc();
		try {
			new LocalConnection().connect( 'foo' );
			new LocalConnection().connect( 'foo' );
		} catch (e:Dynamic) {  }
		#end
	}
	
	/**
	 * Checks whether the swf is loaded from an allowed domain.
	 * Use this to site lock your game.
	 * @param	pDomains	Array of allowed hosts.
	 * @return	True if swf is loaded from any of the allowed domains.
	 */
	public static function isAllowedDomain(pDomains:Array<String>):Bool 
	{
		#if (flash || js)
		var url:String = Pixelizer.stage.loaderInfo.url;
		
		var startCheck:Int = url.indexOf('://') + 3;
		
		if (url.substr(0, startCheck) == 'file://') 
		{
			return true;
		}
		
		var len:Int = url.indexOf('/', startCheck) - startCheck;
		var host:String = url.substr(startCheck, len);
		
		for (domain in pDomains) 
		{
			if (host.substr( -domain.length, domain.length) == domain) 
			{
				return true;
			}
		}
		#end
		
		return false;
	}

}