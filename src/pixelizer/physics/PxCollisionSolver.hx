package pixelizer.physics;

import nme.geom.Point;
import pixelizer.components.collision.PxBoxColliderComponent;
import pixelizer.components.collision.PxGridColliderComponent;
import pixelizer.components.PxBodyComponent;
import pixelizer.Pixelizer;

/**
 * Helper class to solve collisions detected by the collision manager.
 */
class PxCollisionSolver 
{
	
	/**
	 * Constant defining horizontal collision checks.
	 */
	public static inline var HORIZONTAL:Int = 1;
	/**
	 * Constant defining vertical collision checks.
	 */
	public static inline var VERTICAL:Int = 2;
	
	private static var _pt:Point = new Point();
	
	/**
	 * Calculates the overlap between a box and a grid collider. If any.
	 * @param	pBox	Box to check.
	 * @param	pGrid	Grid to check.
	 * @param	pAlignment	Specifies whether to check for vertical or horizontal overlap.
	 * @return	Points containing the overlap.  (0,0) if no overlap.
	 */
	public static function boxGridOverlap(pBox:PxBoxColliderComponent, pGrid:PxGridColliderComponent, pAlignment:Int):Point 
	{
		
		var tile:Int;
		
		var tx1:Int;
		var ty1:Int;
		var tx2:Int;
		var ty2:Int;
		
		var curPos:Point = Pixelizer.pointPool.fetch();
		curPos.x = pBox.entity.transform.position.x;
		curPos.y = pBox.entity.transform.position.y;
		
		var x:Int;
		var y:Int;
		
		var ths:Float = pGrid.cellSize / 2;
		
		var dx:Float;
		var dy:Float;
		var cx:Float;
		var cy:Float;
		
		// modify box position to adapt to grid position
		// will be set back to normal later
		pBox.entity.transform.position.x -= pGrid.entity.transform.position.x;
		pBox.entity.transform.position.y -= pGrid.entity.transform.position.y;
		
		// calc which tiles we might intersect with
		tx1 = Math.floor((pBox.entity.transform.position.x - pBox.collisionBox.halfWidth + pBox.collisionBox.offsetX) / pGrid.cellSize);
		ty1 = Math.floor((pBox.entity.transform.position.y - pBox.collisionBox.halfHeight + pBox.collisionBox.offsetY) / pGrid.cellSize);
		tx2 = Math.floor((pBox.entity.transform.position.x + pBox.collisionBox.halfWidth + pBox.collisionBox.offsetX) / pGrid.cellSize);
		ty2 = Math.floor((pBox.entity.transform.position.y + pBox.collisionBox.halfHeight + pBox.collisionBox.offsetY) / pGrid.cellSize);
		
		// using _pt as projection
		for (y in (ty1)...(ty2 + 1)) 
		{
			for (x in (tx1)...(tx2 + 1)) 
			{
				tile = pGrid.getCell(x, y);
				if (tile > 0) 
				{
					
					// tile center point
					cx = x * pGrid.cellSize + ths;
					cy = y * pGrid.cellSize + ths;
					
					// distance between center points
					dx = Math.abs(cx - (pBox.entity.transform.position.x + pBox.collisionBox.offsetX));
					dy = Math.abs(cy - (pBox.entity.transform.position.y + pBox.collisionBox.offsetY));
					
					_pt.x = _pt.y = 0;
					
					// calculate overlap
					if (dx < ths + pBox.collisionBox.halfWidth) 
					{
						_pt.x = Math.abs(dx - (ths + pBox.collisionBox.halfWidth));
					}
					if (dy < ths + pBox.collisionBox.halfHeight) 
					{
						_pt.y = Math.abs(dy - (ths + pBox.collisionBox.halfHeight));
					}
					
					if (tile == 1) { // SOLID
						// inside a solid tile, push out
						if (_pt.x > 0 && _pt.y > 0) 
						{
							if (pAlignment == PxCollisionSolver.HORIZONTAL) 
							{
								if (cx < pBox.entity.transform.position.x) 
								{
									pBox.entity.transform.position.x += _pt.x;
								} 
								else 
								{
									pBox.entity.transform.position.x -= _pt.x;
								}
							} 
							else 
							{
								if (cy < pBox.entity.transform.position.y) 
								{
									pBox.entity.transform.position.y += _pt.y;
								} 
								else 
								{
									pBox.entity.transform.position.y -= _pt.y;
								}
							}
						}
					} 
					else if (tile == 2) 
					{ // JUMP THROUGH
						if (_pt.x > 0 && _pt.y > 0) 
						{
							if (pAlignment == PxCollisionSolver.VERTICAL) 
							{
								var bodyComp:PxBodyComponent = cast(pBox.entity.getComponentByClass(PxBodyComponent), PxBodyComponent);
								if (bodyComp != null) 
								{
									if (bodyComp.velocity.y >= 0) 
									{
										if (cy >= pBox.entity.transform.position.y) 
										{
											var lastTY:Int = Math.floor((bodyComp.lastPosition.y + pBox.collisionBox.offsetY + pBox.collisionBox.halfHeight - 1) / pGrid.cellSize);
											if (lastTY < y) 
											{
												pBox.entity.transform.position.y -= _pt.y;
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
		
		// remove adaptation to grid position
		pBox.entity.transform.position.x += pGrid.entity.transform.position.x;
		pBox.entity.transform.position.y += pGrid.entity.transform.position.y;
		
		// calc collision response
		_pt.x = pBox.entity.transform.position.x - curPos.x;
		_pt.y = pBox.entity.transform.position.y - curPos.y;
		if (Math.abs(_pt.x) < 0.00000001) 
		{
			_pt.x = 0;
		}
		if (Math.abs(_pt.y) < 0.00000001) 
		{
			_pt.y = 0;
		}
		
		// reset box to original position
		pBox.entity.transform.position.x = curPos.x;
		pBox.entity.transform.position.y = curPos.y;
		
		Pixelizer.pointPool.recycle(curPos);
		
		return _pt;
	
	}
	
	/**
	 * Calculates the overlap between two box colliders. If any.
	 * @param	a	The first box.
	 * @param	b	The other box.
	 * @return	Point containing overlap. (0,0) if no overlap.
	 */
	public static function boxBoxOverlap(a:PxBoxColliderComponent, b:PxBoxColliderComponent):Point 
	{
		_pt.x = _pt.y = 0;
		
		// distance between center points
		var dx:Float = Math.abs((a.entity.transform.position.x + a.collisionBox.offsetX) - (b.entity.transform.position.x + b.collisionBox.offsetX));
		var dy:Float = Math.abs((a.entity.transform.position.y + a.collisionBox.offsetY) - (b.entity.transform.position.y + b.collisionBox.offsetY));
		
		// calculate overlap
		if (dx < a.collisionBox.halfWidth + b.collisionBox.halfWidth) 
		{
			_pt.x = Math.abs(dx - (a.collisionBox.halfWidth + b.collisionBox.halfWidth));
		}
		if (dy < a.collisionBox.halfHeight + b.collisionBox.halfHeight) 
		{
			_pt.y = Math.abs(dy - (a.collisionBox.halfHeight + b.collisionBox.halfHeight));
		}
		
		if (_pt.x == 0 || _pt.y == 0) 
		{
			// no collision (only overlap on one axis)
			_pt.x = _pt.y = 0;
		} 
		else 
		{
			if (a.entity.transform.position.x + a.collisionBox.offsetX > b.entity.transform.position.x + b.collisionBox.offsetX) 
			{
				_pt.x = -_pt.x;
			}
			if (a.entity.transform.position.y + a.collisionBox.offsetY > b.entity.transform.position.y + b.collisionBox.offsetY) 
			{
				_pt.y = -_pt.y;
			}
		}
		
		return _pt;
	}
}