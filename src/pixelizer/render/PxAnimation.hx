package pixelizer.render;

/**
 * Holds all information regarding an animation.
 * @author Johan Peitz
 */
class PxAnimation 
{
	/**
	 * Animation should stop on last from on completion.
	 */
	public static inline var ANIM_STOP:Int = 1;
	/**
	 * Animation should restart after completion.
	 */
	public static inline var ANIM_LOOP:Int = 2;
	/**
	 * Animation should continue into a different animation on completion.
	 */
	public static inline var ANIM_GOTO:Int = 3;
	
	/**
	 * Identifier for this animation.
	 */
	public var label:String;
	/**
	 * Array of frames this animation consists of.
	 */
	public var frames:Array<Int>;
	/**
	 * On completion behaviour.
	 * ANIM_STOP, ANIM_LOOP, ANIM_GOTO
	 */
	public var onComplete:Int;
	/**
	 * What animation to continue into on ANIM_GOTO.
	 */
	public var gotoLabel:String;
	/**
	 * Frame rate of this animation.
	 */
	public var fps:Float;
	
	/**
	 * Creates a new animation.
	 * @param	pLabel	Identifier for this animation.
	 * @param	pFrames	Array of frames this animation consists of.
	 * @param	pFramesPerSecond	Frame rate of this animation.
	 * @param	pOnComplete	On completion behaviour.
	 * @param	pGotoLabel	What animation to continue into on ANIM_GOTO.
	 */
	public function new(pLabel:String, pFrames:Array<Int>, ?pFramesPerSecond:Int = 10, ?pOnComplete:Int = 1/*ANIM_STOP*/, ?pGotoLabel:String = "") 
	{
		label = pLabel;
		frames = pFrames;
		fps = pFramesPerSecond;
		onComplete = pOnComplete;
		gotoLabel = pGotoLabel;
	}

}