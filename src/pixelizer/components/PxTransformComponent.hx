package pixelizer.components;

import nme.geom.Point;
import pixelizer.Pixelizer;

/**
 * Holds each entites transform data such as position, rotation and scale.
 * Every entity has one of there by default.
 * @author Johan Peitz
 */
class PxTransformComponent extends PxComponent 
{
	/**
	 * Local position in relation to the entitie's parent. (The scene, or another entity.(
	 */
	public var position:Point;
	/**
	 * Position on the scene.
	 */
	public var globalPosition:Point;
	/**
	 * Local position from last frame.
	 */
	public var lastPosition:Point;
	/**
	 * The entity's rotation in radians.
	 */
	public var rotation:Float;
	/**
	 * What offset from hotspot to rotate the around.
	 */
	public var pivotOffset:Point;
	/**
	 * The entity's X scale.
	 */
	public var scaleX:Float;
	/**
	 * The entity's Y scale.
	 */
	public var scaleY:Float;
	
	public var scrollFactorX:Float;
	public var scrollFactorY:Float;
	
	/**
	 * Constructs a new transform component and sets the postion.
	 * @param	pX	X position.
	 * @param	pY	Y position.
	 */
	public function new(?pX:Int = 0, ?pY:Int = 0) 
	{
		rotation = 0;
		scaleX = 1;
		scaleY = 1;
		scrollFactorX = 1;
		scrollFactorY = 1;
		
		super();
		globalPosition = Pixelizer.pointPool.fetch();
		globalPosition.x = globalPosition.y = 0;
		
		pivotOffset = Pixelizer.pointPool.fetch();
		pivotOffset.x = pivotOffset.y = 0;
		
		position = Pixelizer.pointPool.fetch();
		position.x = pX;
		position.y = pY;
		
		lastPosition = Pixelizer.pointPool.fetch();
		lastPosition.x = pX;
		lastPosition.y = pY;
	}
	
	/**
	 * Clears all resources used by this component.
	 */
	override public function dispose():Void 
	{
		Pixelizer.pointPool.recycle(globalPosition);
		globalPosition = null;
		
		Pixelizer.pointPool.recycle(lastPosition);
		lastPosition = null;
		
		Pixelizer.pointPool.recycle(position);
		position = null;
		
		Pixelizer.pointPool.recycle(pivotOffset);
		pivotOffset = null;
		
		super.dispose();
	}
	
	/**
	 * Sets the postion in the transform.
	 * @param	pX	X position.
	 * @param	pY	Y position.
	 */
	public function setPosition(pX:Float, pY:Float):Void 
	{
		position.x = pX;
		position.y = pY;
	}
	
	/**
	 * Sets the scale for both X and Y.
	 */
	
	public var scale(null, set_scale):Float;
	
	public function set_scale(pScale:Float):Float 
	{
		scaleX = scaleY = pScale;
		return pScale;
	}

}