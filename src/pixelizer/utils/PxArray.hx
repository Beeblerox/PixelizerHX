package pixelizer.utils;

/**
 * ...
 * @author Zaphod
 */

class PxArray 
{

	public static function indexOf(arrayToCheck:Array<Dynamic>, objectToSearch:Dynamic):Int
	{
		for (i in 0...(arrayToCheck.length))
		{
			if (arrayToCheck[i] == objectToSearch)
			{
				return i;
			}
		}
		
		return -1;
	}
	
}