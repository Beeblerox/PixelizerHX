package examples.platformer;

import pixelizer.components.collision.PxGridColliderComponent;
import pixelizer.components.render.PxTileMapComponent;
import pixelizer.PxEntity;
import pixelizer.render.PxSpriteSheet;
import pixelizer.utils.PxRepository;

/**
 * Shows tiled graphics and holds the collision for the tilemap
 *
 * @author Johan Peitz
 */
class TileMap extends PxEntity 
{
	private var _width:Int;
	private var _height:Int;
	
	private var _gridComponent:PxGridColliderComponent;
	
	public function new(pLevelXML:Xml) 
	{
		super();
		
		var levelXml:Xml = null;
		for (node in pLevelXML.elements())
		{
			if (node.nodeName == "level")
			{
				_width = Std.parseInt(node.get("width"));
				_height = Std.parseInt(node.get("height"));
				levelXml = node;
				break;
			}
		}
		
		// add collision
		_gridComponent = new PxGridColliderComponent(_width, _height, 16);
		
		// add tiled graphics
		var tileMapComp:PxTileMapComponent = new PxTileMapComponent(_width, _height, PxRepository.fetch("tiles"));
		
		for (node in levelXml.elements())
		{
			if (node.nodeName == "solid")
			{
				_gridComponent.grid.populateFromBitString(node.firstChild().toString(), 1);
			}
			else if (node.nodeName == "jump_through")
			{
				_gridComponent.grid.populateFromBitString(node.firstChild().toString(), 2, false);
			}
			else if (node.nodeName == "background")
			{
				tileMapComp.populateFromXML(node);
			}
		}
		
		addComponent(_gridComponent);
		addComponent(tileMapComp);
	}
	
	override public function dispose():Void 
	{
		_gridComponent = null;
		super.dispose();
	}
	
	public var width(get_width, null):Int;
	
	public function get_width():Int 
	{
		return _width;
	}
	
	public var height(get_height, null):Int;
	
	public function get_height():Int 
	{
		return _height;
	}

}