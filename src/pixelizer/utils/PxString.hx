package pixelizer.utils;

/**
 * Utility class for string functions.
 * @author Johan Peitz
 */
class PxString 
{
	
	/**
	 * Trims a string from whitespace.
	 * @param	s	String to trim.
	 * @return	Trimmed string.
	 */
	static public function trim(s:String):String 
	{
		var r = ~/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm;
		return r.replace(s, "$2");
		//return s.replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2");
	}

}