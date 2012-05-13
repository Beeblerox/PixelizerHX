package pixelizer.utils;

/**
 * Handy static function for storing things like sprite sheets
 * and fonts so they can be reused by multiple components with no memory overhead.
 * @author Johan Peitz
 */
class PxRepository 
{
	private static var _storage:Hash<Dynamic> = new Hash<Dynamic>();
	
	/**
	 * Stores an object.
	 * @param	pHandle	Identifier for the object, to fetch it by.
	 * @param	pSheet	The object to store.
	 * @return	Stored object.
	 */
	public static function store(pHandle:String, pObject:Dynamic):Dynamic 
	{
		_storage.set(pHandle, pObject);
		return pObject;
	}
	
	/**
	 * Retrieves an objecy previously stored.
	 * @param	pHandle	Identifier of object to fetch.
	 * @return	Stored object, or null if no object was found.
	 */
	public static function fetch(pHandle:String):Dynamic 
	{
		if (_storage.get(pHandle) == null) 
		{
			PxLog.log("no object found with handle '" + pHandle + "'", "[o PxRepository]", PxLog.WARNING);
		}
		return _storage.get(pHandle);
	}
}