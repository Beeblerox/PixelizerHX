package pixelizer.utils;

/**
 * Holder class for info about the latest logic update.
 * @author Johan Peitz
 */
class PxLogicStats 
{
	/**
	 * Current frame rate.
	 */
	public var fps:Int;
	/**
	 * Time spent doing logic.
	 */
	public var logicTime:Int;
	
	/**
	 * Number of entities updated during logic update.
	 */
	public var entitiesUpdated:Int;
	
	/**
	 * Minimum amount of memory used in mega bytes.
	 */
	public var minMemory:Int;
	/**
	 * Maximum amount of memory used in mega bytes.
	 */
	public var maxMemory:Int;
	/**
	 * Current amount of memory used in mega bytes.
	 */
	public var currentMemory:Int;
	
	public function new()
	{
		minMemory = -1;
		maxMemory = -1;
		currentMemory = -1;
	}
	
	/**
	 * Resets data making it ready for the next update.
	 */
	public function reset():Void 
	{
		entitiesUpdated = 0;
	}

}