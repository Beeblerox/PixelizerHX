package pixelizer.components.render;

import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;
import pixelizer.Pixelizer;
import pixelizer.render.PxSpriteSheet;
import pixelizer.utils.PxGrid;
import pixelizer.utils.PxRenderStats;

/**
 * Renders tiles using a sprite sheet.
 * @author Johan Peitz
 */
class PxTileMapComponent extends PxBlitRenderComponent 
{
	private var _grid:PxGrid;
	
	private var _numTiles:Int;
	
	private var _tileBounds:Rectangle;
	private var _tileSheet:PxSpriteSheet;
	
	/**
	 * Constructs a new tile map.
	 * @param	pWidth	Width of map in tiles.
	 * @param	pHeight	Height of map in tiles.
	 * @param	pSpriteSheet	Sprite sheet to use for tiles.
	 */
	public function new(pWidth:Int, pHeight:Int, pSpriteSheet:PxSpriteSheet) 
	{
		_numTiles = 0;
		super();
		
		_tileSheet = pSpriteSheet;
		_tileBounds = new Rectangle(0, 0, _tileSheet.spriteWidth, _tileSheet.spriteHeight);
		
		_grid = new PxGrid(pWidth, pHeight, -1);
	}
	
	/**
	 * Clears all resources used by tile map.
	 */
	override public function dispose():Void 
	{
		_tileBounds = null;
		_grid.dispose();
		_grid = null;
		_tileSheet = null;
		
		super.dispose();
	}
	
	/**
	 * Sets a tile on the map to use a specific frame from the sprite sheet.
	 * @param	pTX	X position of tile.
	 * @param	pTY	Y position of tile.
	 * @param	pTileID	Frame to use.
	 */
	public function setTile(pTX:Int, pTY:Int, pTileID:Int):Void 
	{
		var prevTileID:Int = _grid.getCell(pTX, pTY);
		_grid.setCell(pTX, pTY, pTileID);
		
		if (prevTileID > 0) 
		{
			_numTiles += (pTileID == 0 ? -1 : 0);
		} 
		else 
		{
			_numTiles += (pTileID == 0 ? 0 : 1);
		}
	}
	
	/**
	 * Returns the grid that holds tile values.
	 * @return The tile grid.
	 */
	
	public var grid(get_grid, null):PxGrid;
	
	public function get_grid():PxGrid 
	{
		return _grid;
	}
	
	/**
	 * Returns number of tiles in the map.
	 * @return Amount of tiles in map.
	 */
	
	public var numTiles(get_numTiles, null):Int;
	
	public function get_numTiles():Int 
	{
		return _numTiles;
	}
	
	/**
	 * Populates the map from XML. XML should look like this.
	 * <data>
	 * 		<tile x="12" y="23" id="2" />
	 * </data>
	 *
	 * @param	pXML XML to use.
	 */
	public function populateFromXML(pXML:Xml):Void 
	{
		for (node in pXML.elementsNamed("tile")) 
		{
			setTile(Std.parseInt(node.get("x")), Std.parseInt(node.get("y")), Std.parseInt(node.get("id")));
		}
	}
	
	/**
	 * Renders the tilemap onto bitmap data.
	 * @param	pView	Part of scene to render.
	 * @param	pBitmapData	Bitmap data to render on.
	 * @param	pOffset		Offset from top left corner.
	 * @param	pRenderStats	Render stats to update.
	 */
	override public function render(pView:Rectangle, pBitmapData:BitmapData, pOffset:Point, pRotation:Float, pScaleX:Float, pScaleY:Float, pRenderStats:PxRenderStats ):Void 
	{
		if (!visible)
		{
			return;
		}
		
		var tileSize:Int = _tileSheet.spriteWidth;
		
		var objsRendered:Int = 0;
		
		var dest:Point = Pixelizer.pointPool.fetch();
		
		var len:Int = grid.width * grid.height;
		var pos:Int = 0;
		
		var tx:Int;
		var ty:Int;
		
		var x1:Int = Math.floor(Math.max(pView.x / tileSize, 0));
		var x2:Int = Math.floor(Math.min((pView.x + pView.width) / tileSize + 1, grid.width));
		
		var y1:Int = Math.floor(Math.max(pView.y / tileSize, 0));
		var y2:Int = Math.floor(Math.min((pView.y + pView.height) / tileSize + 1, grid.height));
		
		for (ty in (y1)...(y2)) 
		{
			pos = ty * grid.width + x1;
			for (tx in (x1)...(x2)) 
			{
				var id:Int = grid.getCell(tx, ty);
				if (id > -1) 
				{
					dest.x = pOffset.x + tx * tileSize - pView.x;
					dest.y = pOffset.y + ty * tileSize - pView.y;
					
					pBitmapData.copyPixels(_tileSheet.getFrame(id, 0), _tileBounds, dest, null, null, true);
					
					objsRendered++;
				}
				pos++;
			}
		}
		
		Pixelizer.pointPool.recycle(dest);
		
		pRenderStats.renderedObjects += objsRendered;
		pRenderStats.totalObjects += numTiles;
	}

}