package examples;

import flash.display.Sprite;
import pixelizer.Pixelizer;
import pixelizer.PxEngine;

/**
 *
 * @author Johan Peitz
 */
class ExampleLauncher extends Sprite 
{
	
	public function new() 
	{
		super();
		
		var engine:PxEngine = new PxEngine(320, 240, 2);
		addChild(engine);

		// engine.showPerformance = true;
		// engine.pauseOnFocusLost = false;
		
		engine.pushScene(new MenuScene());
	}

}