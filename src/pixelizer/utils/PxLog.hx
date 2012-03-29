package pixelizer.utils;

import nme.Lib;

/**
 * Class used to log messaged to console and other recievers.
 */
class PxLog {
	/**
	 * Denotes a log entry as debug.
	 */
	public static inline var DEBUG:Int = 0;
	/**
	 * Denotes a log entry as information.
	 */
	public static inline var INFO:Int = 1;
	/**
	 * Denotes a log entry as a warning.
	 */
	public static inline var WARNING:Int = 2;
	/**
	 * Denotes a log entry as an error.
	 */
	public static inline var ERROR:Int = 3;
	/**
	 * Denotes a log entry as a fatal error (very bad!).
	 */
	public static inline var FATAL:Int = 4;
	
	private static var _indentation:Int = 0;
	private static inline var _prefix:Array<String> = ["   ", "---", "???", "!!!", "***"];
	#if flash
	private static var _outputs:Array<Dynamic> = [Lib.trace];
	#else
	private static var _outputs:Array<Dynamic> = [];
	#end
	
	/**
	 * Sends a string of text to any listening functions. ( At least trace(...). )
	 * @param	pText	String to log.
	 * @param	pCaller	Object that creats the string. Usually pass 'this'.
	 * @param	pLevel	Importance level of message.
	 */
	public static function log(pText:String, ?pCaller:Dynamic = null, ?pLevel:Int = 0/*DEBUG*/ ):Void 
	{
		var str:String = "";
		var caller:String = "?";
		if (pCaller != null) 
		{
			caller = getObjectString(pCaller);
		}
		
		var spaces:String = "";
		if (caller.length > _indentation) 
		{
			_indentation = caller.length;
		}
		var target:Int = _indentation - caller.length;
		while (spaces.length < target) 
		{
			spaces += " ";
		}
		str = spaces + "[" + caller + "] " + _prefix[pLevel] + " " + pText;
		
		for (f in _outputs) 
		{
			f(str);
		}
	}
	
	/**
	 * Adds a function that will recieve log output everytime PxLog.log is called.
	 * @param	pFunction	Function send log output to.
	 */
	static public function addLogFunction(pFunction:Dynamic):Void 
	{
		_outputs.push(pFunction);
	}
	
	private static function getObjectString(pObject:Dynamic):String 
	{
		var objAsString:String = Std.string(pObject);
		var start:Int = objAsString.indexOf(" ") + 1;
		var end:Int = objAsString.indexOf("]");
		//return objAsString.slice(start, end);
		return objAsString.substr(start, (objAsString.length - end - 1));
	}
}