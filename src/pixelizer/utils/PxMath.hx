package pixelizer.utils;

/**
 * Contains various mathematical functions and structures.
 * @author Johan Peitz
 */
class PxMath 
{
	/**
	 * A half PI.
	 */
	public static inline var HALF_PI:Float = Math.PI / 2;
	/**
	 * The whole PI.
	 */
	public static inline var PI:Float = Math.PI;
	/**
	 * A double PI.
	 */
	public static inline var TWO_PI:Float = PI * 2;
	/**
	 * Multiply with this to convert radians to degrees.
	 */
	public static inline var RAD_TO_DEG:Float = 180 / Math.PI;
	/**
	 * Multiply with this to convert degrees to radians.
	 */
	public static inline var DEG_TO_RAD:Float = Math.PI / 180;
	
	/**
	 * Converts an angle to fit within the unit circle.
	 * @param	pRadians	Angle to convert.
	 * @return	Converted angle.
	 */
	public static function wrapAngle(pRadians:Float):Float 
	{
		while (pRadians < -PI) 
		{
			pRadians += TWO_PI;
		}
		while (pRadians > PI) 
		{
			pRadians -= TWO_PI;
		}
		return pRadians;
	}
	
	/**
	 * Returns the shortest angle between two angles.
	 * @param	pRadians1	Angle 1.
	 * @param	pRadians2	Angle 2.
	 * @return	The shortest angle.
	 */
	public static function deltaAngle(pRadians1:Float, pRadians2:Float ):Float 
	{
		return Math.abs(wrapAngle(pRadians1 - pRadians2));
	}
	
	/**
	 * Returns the sign of a number.
	 * @param	pValue	Number to check.
	 * @return	Sign of number. ( -1, 0, or 1 )
	 */
	public static function sign(pValue:Float):Int 
	{
		return (pValue > 0 ? 1 : (pValue < 0 ? -1 : 0));
	}
	
	/**
	 * Returns a random number within a scope.
	 * @param	pMin	Minimum result (inclusive).
	 * @param	pMax	Maximum result (exclusive).
	 * @return	A random number.
	 */
	public static function randomNumber(pMin:Float, pMax:Float):Float 
	{
		return pMin + ( pMax - pMin ) * Math.random();
	}
	
	/**
	 * Returns a random int within a scope.
	 * @param	pMin	Minimum result (inclusive).
	 * @param	pMax	Maximum result (exclusive).
	 * @return	A random int.
	 */
	public static function randomInt(pMin:Int, pMax:Int):Int 
	{
		return Math.floor(pMin + (pMax - pMin) * Math.random());
	}
	
	/**
	 * Returns a random boolean.
	 * @return	True or false.
	 */
	public static function randomBoolean():Bool 
	{
		return Math.random() < 0.5;
	}
	
	/**
	 * Uses quick and approximate algorithm to get sin value.
	 * @see http://lab.polygonal.de/?p=205
	 * @param	pRaidans	Angle to use for calculation.
	 * @return	Approximative sin value.
	 */
	public static function sin(pRaidans:Float):Float 
	{
		var result:Float;
		
		pRaidans = wrapAngle(pRaidans);
		
		//compute sine
		if (pRaidans < 0) 
		{
			result = 1.27323954 * pRaidans + .405284735 * pRaidans * pRaidans;
			
			if (result < 0)
			{
				result = .225 * (result * -result - result) + result;
			}
			else
			{
				result = .225 * (result * result - result) + result;
			}
		} 
		else 
		{
			result = 1.27323954 * pRaidans - 0.405284735 * pRaidans * pRaidans;
			
			if (result < 0)
			{
				result = .225 * (result * -result - result) + result;
			}
			else
			{
				result = .225 * (result * result - result) + result;
			}
		}
		
		return result;
	}
	
	/**
	 * Uses quick and approximate algorithm to get cos value.
	 * @see http://lab.polygonal.de/?p=205
	 * @param	pRaidans	Angle to use for calculation.
	 * @return	Approximative cos value.
	 */
	public static function cos(pRaidans:Float):Float 
	{
		var result : Float;
		
		// only difference from sin is start angle
		pRaidans += HALF_PI;
		pRaidans = wrapAngle(pRaidans);
		
		//compute cosine
		if (pRaidans < 0) 
		{
			result = 1.27323954 * pRaidans + 0.405284735 * pRaidans * pRaidans;
			
			if (result < 0)
			{
				result = .225 * (result * -result - result) + result;
			}
			else
			{
				result = .225 * (result * result - result) + result;
			}
		} 
		else 
		{
			result = 1.27323954 * pRaidans - 0.405284735 * pRaidans * pRaidans;
			
			if (result < 0)
			{
				result = .225 * (result * -result - result) + result;
			}
			else
			{
				result = .225 * (result * result - result) + result;
			}
		}
		return result;
	}

}