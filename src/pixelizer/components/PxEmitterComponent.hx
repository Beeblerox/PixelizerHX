package pixelizer.components;

import nme.geom.Point;
import pixelizer.IPxEntityContainer;
import pixelizer.PxEntity;
import pixelizer.utils.PxMath;

/**
 * Easy way to emit other entities.
 * @author Johan Peitz
 */
class PxEmitterComponent extends PxComponent 
{
	private var _emittedEntityClass:Class<PxEntity>;
	
	private var _numSimulEntities:Int;
	private var _numTotalEntities:Int;
	
	private var _emitDelay:Point;
	private var _emitForce:Point;
	private var _emitAngle:Point;
	private var _emitLife:Point;
	
	private var _emitDelayTarget:Float;
	private var _emitDelayProgress:Float;
	private var _totalEntitiesEmitted:Int;
	
	private var _numEntitiesEmitted:Int;
	
	private var _emitTo:IPxEntityContainer;
	
	/**
	 * Constructs a new component.
	 * @param	pEntityClassToEmit	Entity to emit.
	 * @param	pEmitTo	Where the emitted entities should be added. If null they will be emitted added to the component's entity.
	 */
	public function new(pEntityClassToEmit:Class<PxEntity>, ?pEmitTo:IPxEntityContainer = null) 
	{
		_numSimulEntities = 1;
		_numTotalEntities = -1;
		_emitDelay = new Point(1, 1);
		_emitForce = new Point(0, 0);
		_emitAngle = new Point(0, 0);
		_emitLife = new Point(0, 0);
		_emitDelayTarget = 0;
		_emitDelayProgress = 0;
		_totalEntitiesEmitted = 0;
		_numEntitiesEmitted = 0;
		super();
		
		_emitTo = pEmitTo;
		_emittedEntityClass = pEntityClassToEmit;
		_emitDelayTarget = PxMath.randomNumber(_emitDelay.x, _emitDelay.y);
	}
	
	/**
	 * Clears resources used.
	 */
	public override function dispose():Void 
	{
		_emitTo = null;
		super.dispose();
	}
	
	/**
	 * Updates the emitter. Emits new entity if needed.
	 * @param	pDT
	 */
	public override function update(pDT:Float):Void 
	{
		_emitDelayProgress += pDT;
		
		if (_emitDelayProgress > _emitDelayTarget) {
			_emitDelayProgress -= _emitDelayTarget;
			_emitDelayTarget = PxMath.randomNumber(_emitDelay.x, _emitDelay.y);
			
			if (_totalEntitiesEmitted < _numTotalEntities || _numTotalEntities == -1) 
			{
				if (_numEntitiesEmitted < _numSimulEntities || _numSimulEntities == -1) 
				{
					// emit!
					var entityToEmit:PxEntity = Type.createInstance(_emittedEntityClass, []);
					if (_emitTo != null && _emitTo != entity) 
					{
						entityToEmit.transform.position.x = entity.transform.position.x;
						entityToEmit.transform.position.y = entity.transform.position.y;
					}
					
					var body:PxBodyComponent = cast(entityToEmit.getComponentByClass(PxBodyComponent), PxBodyComponent);
					if (body != null) 
					{
						var a:Float = PxMath.randomNumber(_emitAngle.x, _emitAngle.y);
						var f:Float = PxMath.randomNumber(_emitForce.x, _emitForce.y);
						var vel:Point = new Point(f * PxMath.cos(a), f * PxMath.sin(a));
						
						body.velocity.x += vel.x;
						body.velocity.y += vel.y;
					}
					
					if (_emitLife.y > 0) 
					{
						entityToEmit.destroyIn(PxMath.randomNumber( _emitLife.x, _emitLife.y));
					}
					
					if (_emitTo == null) 
					{
						entity.addEntity(entityToEmit);
					} 
					else 
					{
						_emitTo.addEntity(entityToEmit);
					}
					
					entityToEmit.addOnRemovedCallback(onEmittedEntityRemovedFromScene);
					
					_numEntitiesEmitted++;
					_totalEntitiesEmitted++;
				}
				
				super.update(pDT);
			}
		}
	
	}
	
	/**
	 * Keeps track of number of emitted entites.
	 * Invoked when an emitted entity is removed.
	 * @param	pEntity
	 */
	private function onEmittedEntityRemovedFromScene(pEntity:PxEntity):Void 
	{
		_numEntitiesEmitted--;
	}
	
	/**
	 * Sets the number of emitted entities that can exists at the same time.
	 * If this number is reached, one of the entities must be removed before a new one is emitted.
	 * @param	value	Number of entites that can exists at the same time.
	 */
	public function setNumSimulEntities(value:Int):Void 
	{
		_numSimulEntities = value;
	}
	
	/**
	 * Total number of entities this emitter will emit.
	 * When this number is reached, no more entities will be emitted.
	 * @param	value	Total number of entities.
	 */
	public function setNumTotalEntities(value:Int):Void 
	{
		_numTotalEntities = value;
	}
	
	/**
	 * Sets the range of the delay between each emitted entity.
	 * @param	pMin	Minimum time to wait. (Seconds.)
	 * @param	pMax	Maximum time to wait. (Seconds.)
	 */
	public function setEmitDelayRange(pMin:Float, pMax:Float):Void 
	{
		_emitDelay.x = pMin;
		_emitDelay.y = pMax;
		
		_emitDelayProgress = 0;
		_emitDelayTarget = PxMath.randomNumber(_emitDelay.x, _emitDelay.y);
	}
	
	/**
	 * Sets the range of the force that emitted entities are given.
	 * This only applies if emitted entity has a body component.
	 * @param	pMin	Minimum emit force.
	 * @param	pMax	Maximum emit force.
	 */
	public function setEmitForceRange(pMin:Float, pMax:Float):Void 
	{
		_emitForce.x = pMin;
		_emitForce.y = pMax;
	}
	
	/**
	 * Controls the angles that emitted entities will have. Only applies if there is also an emit force.
	 * @param	pMin	Minimum angle in radians.
	 * @param	pMax	Maximum angle in radians.
	 */
	public function setEmitAngleRange(pMin:Float, pMax:Float ):Void 
	{
		_emitAngle.x = pMin;
		_emitAngle.y = pMax;
	}
	
	/**
	 * Sets the life time range of emitted entities.
	 * @param	pMin	Minimum life time in seconds.
	 * @param	pMax	Maximum life time in seconds.
	 */
	public function setEmitLifeRange(pMin:Float, pMax:Float):Void 
	{
		_emitLife.x = pMin;
		_emitLife.y = pMax;
	}

}