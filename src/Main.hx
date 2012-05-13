package ;

import examples.ExampleLauncher;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.Lib;

/**
 * ...
 * @author Zaphod
 */

class Main 
{
	public function new()
	{
		
	}
	
	public static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		// entry point
		
		var launcher:ExampleLauncher = new ExampleLauncher();
		stage.addChild(launcher);
	}
	
}