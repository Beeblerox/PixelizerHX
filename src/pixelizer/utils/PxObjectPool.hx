package pixelizer.utils;

/**
 * A standard object pool to get rid of inefficient instanciation.
 * @author Johan Peitz
 */
class PxObjectPool 
{
	private var _objectClass:Class<Dynamic>;
	private var _objects:Array<Dynamic>;
	
	/**
	 * Constructs a new object pool of the desired type.
	 * @param	pClass	The class that this pool should keep.
	 * @param	pInitialSize	Initial size of pool.
	 */
	public function new(pClass:Class<Dynamic>, ?pInitialSize:Int = 0) 
	{
		_objectClass = pClass;
		_objects = [];
		for (i in 0...(pInitialSize)) 
		{
			_objects.push(Type.createInstance(_objectClass, []));
		}
	}
	
	/**
	 * Returns an instanciated class. If the pool is empty, a new instance will be created.
	 * If there are instances in the pool, one of them will be returned.
	 * @param	pFunction	Function to apply to object. Can be used to reset values.
	 * @param	pArgs	Arguments to pass to above function.
	 * @return	An instanciated class of the pool's type.
	 */
	public function fetch(?pFunction:String = null, ?pArgs:Array<Dynamic> = null):Dynamic 
	{
		var obj:Dynamic;
		
		if (_objects.length > 0) 
		{
			obj = _objects.pop();
		} 
		else 
		{
			obj = Type.createInstance(_objectClass, []);
		}
		
		if (pFunction != null) 
		{
			//obj[pFunction].apply(obj, pArgs);
			Reflect.callMethod(obj, Reflect.field(obj, pFunction), pArgs);
		}
		
		return obj;
	}
	
	/**
	 * Recycles an object. Usually it was fetched from the pool earlier, but that's not needed.
	 * @param	pObject
	 */
	public function recycle(pObject:Dynamic):Void 
	{
		_objects.push(pObject);
	}
	
	/**
	 * Clears the pool of all instances. No dispose or any other functions are applied to the objects.
	 */
	public function purge():Void 
	{
		_objects = [];
	}
	
	/**
	 * Returns the size of the pool.
	 * @return Size of pool.
	 */
	
	public var size(get_size, null):Int;
	
	public function get_size():Int 
	{
		return _objects.length;
	}

}