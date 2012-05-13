package pixelizer;

import nme.display.Sprite;
import nme.events.Event;
import nme.events.FocusEvent;
import nme.events.TimerEvent;
import nme.geom.Point;
import nme.Lib;
import nme.system.System;
import nme.utils.Timer;
import pixelizer.components.collision.PxColliderComponent;
import pixelizer.components.render.PxBlitRenderComponent;
import pixelizer.components.render.PxTextFieldComponent;
import pixelizer.prefabs.gui.PxTextFieldEntity;
import pixelizer.prefabs.logo.PxLogoEntity;
import pixelizer.render.IPxRenderer;
import pixelizer.render.PxBlitRenderer;
import pixelizer.sound.PxSoundManager;
import pixelizer.utils.PxCollisionStats;
import pixelizer.utils.PxImageUtil;
import pixelizer.utils.PxLog;
import pixelizer.utils.PxLogicStats;
import pixelizer.utils.PxRenderStats;
import pixelizer.utils.PxString;

/**
 * The engine manages and updates scenes. Inherit the engine with your document class to get rolling!
 * @author	Johan Peitz
 */
class PxEngine extends Sprite 
{
	private var _pauseOnFocusLost:Bool;
	
	private var _renderer:IPxRenderer;
	private var _logicStats:PxLogicStats;
	
	private var _currentScene:PxScene;
	private var _sceneStack:Array<PxScene>;
	private var _sceneChanges:Array<Dynamic>;
	
	private var _renderClass:Class<IPxRenderer>;
	
	private var _internalScene:PxScene;
	private var _performaceView:PxTextFieldEntity;
	private var _logView:PxTextFieldEntity;
	private var _logTexts:Array<String>;
	
	private var _targetFPS:Int;
	
	private var _frameCount:Int;
	private var _fpsTimer:Timer;
	private var _internalTimer:Timer;
	
	private var _timeStepS:Float;
	private var _timeStepMS:Float;
	private var _currentTimeMS:Float;
	private var _lastTimeMS:Float;
	private var _deltaTimeMS:Float;
	
	private var _width:Int;
	private var _height:Int;
	private var _scale:Int;
	private var _showingLogo:Bool;
	private var _hasFocus:Bool;
	private var _noFocusEntity:PxEntity;
	
	/**
	 * Constructs a new engine. Automatically initializes Pixelizer. Sets the dimensions for the renderer.
	 * The size of the renderer and the scale should match the size of the application.
	 *
	 * @param	pWidth	Width of renderer.
	 * @param	pHeight	Height of renderer.
	 * @param	pScale	How much to scale the renderer.
	 * @param	pFPS	Target Frames Per Seconds.
	 * @param	pRendererClass	What renderer to use.
	 * @param 	pShowLogo	Specifies whether to show Pixelizer logo at start or not.
	 */
	public function new(pWidth:Int, pHeight:Int, ?pScale:Int = 1, ?pFPS:Int = 30, ?pRendererClass:Class<IPxRenderer> = null, ?pShowLogo:Bool = true) 
	{
		_pauseOnFocusLost = true;
		_logTexts = [];
		_frameCount = 0;
		_timeStepS = 0;
		_timeStepMS = 0;
		_currentTimeMS = 0;
		_lastTimeMS = 0;
		_deltaTimeMS = 0;
		_hasFocus = true;
		super();
		
		Pixelizer.init();
		Pixelizer.engine = this;
		
		_showingLogo = pShowLogo;
		_targetFPS = pFPS;
		_width = pWidth;
		_height = pHeight;
		_scale = pScale;
		_renderClass = pRendererClass;
		
		if (_renderClass == null) 
		{
			_renderClass = PxBlitRenderer;
		}
		
		_logicStats = new PxLogicStats();
		
		_currentScene = null;
		_sceneStack = new Array<PxScene>();
		_sceneChanges = [];
		
		_internalScene = new PxScene();
		_internalScene.onAddedToEngine(this);
		_internalScene.background = false;

		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	
	private function onAddedToStage(pEvent:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
		Pixelizer.onEngineAddedToStage(this, stage);
		
		
		PxLog.addLogFunction(logListener);
		PxLog.log("size set to " + _width + "x" + _height + ", " + _scale + "x", this, PxLog.INFO);
		
		_renderer = Type.createInstance(_renderClass, [_width, _height, _scale]);
		addChild(_renderer.displayObject);
		
		if (_showingLogo) 
		{
			_internalScene.addEntity(new PxLogoEntity(onLogoComplete));
		}
		
		_timeStepMS = 1000 / _targetFPS;
		_timeStepS = _timeStepMS / 1000;
		_lastTimeMS = _currentTimeMS = Lib.getTimer();
		
		_fpsTimer = new Timer(1000);
		_fpsTimer.addEventListener(TimerEvent.TIMER, onFpsTimer);
		_fpsTimer.start();
		
		_internalTimer = new Timer(10);
		_internalTimer.addEventListener(TimerEvent.TIMER, internalUpdate);
		_internalTimer.start();
		
		stage.focus = this;
		stage.addEventListener(Event.ACTIVATE, onFocusIn);
		stage.addEventListener(Event.DEACTIVATE, onFocusOut);
	}
	
	/**
	 * Cleans up after the engine. Freeing resources.
	 */
	public function dispose():Void 
	{
		if (_internalTimer != null) 
		{
			_internalTimer.stop();
			_internalTimer.addEventListener(TimerEvent.TIMER, internalUpdate);
			_internalTimer = null;
		}
		
		if (_internalTimer != null) 
		{
			_fpsTimer.stop();
			_fpsTimer.addEventListener(TimerEvent.TIMER, onFpsTimer);
			_fpsTimer = null;
		}
		
		stage.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
		stage.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
	}
	
	private function logListener(pMessage:String):Void 
	{
		_logTexts.push(pMessage);
		if (_logTexts.length > 3) 
		{
			_logTexts.shift();
		}
		
		if (_logView != null) 
		{
			_logView.textField.text = getLogText();
		}
	}
	
	private function getLogText():String 
	{
		var s:String = "";
		for (txt in _logTexts) 
		{
			s += PxString.trim(txt) + "\n";
		}
		return s;
	}
	
	private function onFocusIn(evt:Event):Void 
	{
		if (!_pauseOnFocusLost) 
		{
			return;
		}
			
		if (_hasFocus)
		{
			return;
		}
		
		if (!_internalTimer.running) 
		{
			_internalTimer.start();
			_lastTimeMS = Lib.getTimer();
			_hasFocus = true;
		}
		
		if (_noFocusEntity != null) 
		{
			_internalScene.removeEntity(_noFocusEntity);
			_noFocusEntity = null;
		}
		
		PxSoundManager.unpause();
	}
	
	private function onFocusOut(evt:Event):Void 
	{
		if (!_pauseOnFocusLost) 
		{
			return;
		}
			
		if (!_hasFocus)
		{
			return;
		}
		
		_hasFocus = false;
		
		_noFocusEntity = new PxEntity();
		_noFocusEntity.transform.scale = 2;
		var blocker:PxBlitRenderComponent = new PxBlitRenderComponent(PxImageUtil.createRect(Math.floor(_width / 2), Math.floor(_height / 2), Pixelizer.COLOR_LIGHT_GRAY), new Point());
		blocker.alpha = 0.5;
		_noFocusEntity.addComponent(blocker);
		var message:PxTextFieldComponent = new PxTextFieldComponent();
		message.text = "*** PAUSED ***\n\nClick to resume.";
		message.background = true;
		message.alignment = Pixelizer.CENTER;
		message.padding = 10;
		message.width = Math.floor(_width / 2 - 20);
		message.setHotspot(0, Math.floor(-_height / 4 + 30));
		
		_noFocusEntity.addComponent(message);
		_internalScene.addEntity(_noFocusEntity);
	}
	
	/**
	 * Resets the engine's timers.
	 * Should be called after time consuming algorithms so that the engine does not skip frames afterwards.
	 */
	public function resetTimers():Void 
	{
		_lastTimeMS = _currentTimeMS = Lib.getTimer();
	}
	
	private function onFpsTimer(evt:TimerEvent):Void 
	{
		_logicStats.fps = _frameCount;
		_frameCount = 0;
		
		if (_performaceView != null) 
		{
			_logicStats.currentMemory = Math.floor(System.totalMemory / 1024 / 1024);
			if (_logicStats.maxMemory < _logicStats.currentMemory) 
			{
				_logicStats.maxMemory = _logicStats.currentMemory;
			}
			if (_logicStats.minMemory == -1 || _logicStats.minMemory > _logicStats.currentMemory) 
			{
				_logicStats.minMemory = _logicStats.currentMemory;
			}
			var text:String = "";
			text += "FPS: " + logicStats.fps + "\n";
			text += "Logic: " + logicStats.logicTime + " ms" + "\n";
			text += "Entities: " + logicStats.entitiesUpdated + "\n";
			text += "Colliders: " + collisionStats.colliderObjects + "\n";
			text += "Collisions: " + collisionStats.collisionHits + "/" + collisionStats.collisionMasks + "/" + collisionStats.collisionTests + "\n";
			text += "Render: " + renderStats.renderTime + " ms" + "\n";
			text += "RendObjs: " + renderStats.renderedObjects + "/" + renderStats.totalObjects + "\n";
			text += "Memory: " + _logicStats.minMemory + "/" + _logicStats.currentMemory + "/" + _logicStats.maxMemory + " MB";
			_performaceView.textField.text = text;
		}
	}
	
	private function internalUpdate(evt:TimerEvent):Void 
	{
		var logicTime:Int;
		
		_currentTimeMS = Lib.getTimer();
		_deltaTimeMS += _currentTimeMS - _lastTimeMS;
		_lastTimeMS = _currentTimeMS;
		
		if (_deltaTimeMS >= _timeStepMS) 
		{
			// do logic
			while (_deltaTimeMS >= _timeStepMS) 
			{
				_logicStats.reset();
				
				_deltaTimeMS -= _timeStepMS;
				
				// track logic performance
				logicTime = Lib.getTimer();
				
				// update input
				PxInput.update( _timeStepS );
				
				// update current scene
				if (_currentScene != null && _showingLogo == false) 
				{
					_currentScene.update(_timeStepS);
				}
				
				// update internal scene
				_internalScene.update(_timeStepS);
				
				// finalize input
				PxInput.afterUpdate();
				
				// calc logic time					
				_logicStats.logicTime = Lib.getTimer() - logicTime;
			}
			
			// count fps
			_frameCount++;
			
			// render
			_renderer.beforeRendering();
			// render scenes
			if (_currentScene != null) 
			{
				_renderer.render( _currentScene );
			}
			
			// render internal scene on top 
			_renderer.render(_internalScene);
			_renderer.afterRendering();
			
			// make changes to scenes
			if (_sceneChanges.length > 0) 
			{
				for (o in _sceneChanges) 
				{
					switch (o.action) 
					{
						case "pop": 
							internalPopScene();
						case "push": 
							internalPushScene( o.scene );
					}
				}
				_sceneChanges = [];
			}
			
			// stop the internal timer if we lost focus
			if (!_hasFocus) 
			{
				_internalTimer.stop();
				PxSoundManager.pause();
				PxInput.reset();
			}
			
			// move on as fast as possible
			evt.updateAfterEvent();
		}
	}
	
	/**
	 * Returns the renderer.
	 * @return The renderer.
	 */
	
	public var renderer(get_renderer, null):IPxRenderer;
	
	public function get_renderer():IPxRenderer 
	{
		return _renderer;
	}
	
	/**
	 * Adds a scene to the top of the scene stack. The added scene will now be the current scene.
	 * @param	pScene
	 */
	public function pushScene(pScene:PxScene):Void 
	{
		_sceneChanges.push({action: "push", scene: pScene});
	}
	
	private function internalPushScene(pScene:PxScene):Void 
	{
		PxLog.log("pushing scene '" + pScene + "' on stack", this, PxLog.INFO);
		_sceneStack.push(pScene);
		_currentScene = pScene;
		_currentScene.onAddedToEngine(this);
	}
	
	/**
	 * Removes to top most scene from the stack and sets the scene below to become the current scene.
	 */
	public function popScene():Void 
	{
		_sceneChanges.push({action: "pop", scene: null});
	}
	
	private function internalPopScene():Void 
	{
		PxLog.log("popping scene '" + _currentScene + "' from stack", this, PxLog.INFO);
		
		var lastScene:PxScene = _sceneStack.pop();
		lastScene.onRemovedFromEngine();
		
		if (_sceneStack.length > 0) 
		{
			_currentScene = _sceneStack[_sceneStack.length - 1];
		} 
		else 
		{
			_currentScene = null;
		}
		
		PxLog.log("current scene is '" + _currentScene + "'", this, PxLog.INFO);
	}
	
	/**
	 * Returns whether the engine is showing the performance info or not.
	 * @return True is performance info is currently shown.
	 */
	
	public var showPerformance(get_showPerformance, set_showPerformance):Bool;
	
	public function get_showPerformance():Bool 
	{
		return _performaceView != null;
	}
	
	/**
	 * Specifies whether to show performance info or not.
	 */
	public function set_showPerformance(pShowPerformance:Bool):Bool 
	{
		if (_performaceView == null && pShowPerformance) 
		{
			PxLog.log("turning performance view ON", "[o Pixelizer]", PxLog.DEBUG);
			_performaceView = new PxTextFieldEntity("", Pixelizer.COLOR_BLACK);
			_performaceView.textField.background = true;
			_performaceView.textField.backgroundColor = Pixelizer.COLOR_LIGHT_GRAY;
			_performaceView.textField.padding = 2;
			_performaceView.textField.alpha = 0.8;
			_internalScene.entityRoot.addEntity(_performaceView);
			
			_logView = new PxTextFieldEntity("", Pixelizer.COLOR_BLACK);
			_logView.textField.background = true;
			_logView.textField.backgroundColor = Pixelizer.COLOR_LIGHT_GRAY;
			_logView.textField.padding = 2;
			_logView.textField.alpha = 0.8;
			_logView.textField.width = _width;
			_logView.transform.position.y = _height - 25;
			_logView.textField.text = getLogText();
			_internalScene.entityRoot.addEntity(_logView);
		}
		
		if (_performaceView != null && !pShowPerformance) 
		{
			PxLog.log("turning performance view OFF", "[o Pixelizer]", PxLog.DEBUG);
			_internalScene.entityRoot.removeEntity( _performaceView );
			_performaceView.dispose();
			_performaceView = null;
			
			_internalScene.entityRoot.removeEntity( _logView );
			_logView.dispose();
			_logView = null;
		}
		
		return pShowPerformance;
	}
	
	private function onLogoComplete():Void 
	{
		_showingLogo = false;
	}
	
	/**
	 * Returns the width of the engine.
	 * @return	Width of the engine.
	 */
	
	public var engineWidth(get_width, null):Int;
	
	public function get_width():Int 
	{
		return _width;
	}
	
	/**
	 * Returns the height of the engine.
	 * @return	Height of the engine.
	 */
	
	public var engineHeight(get_height, null):Int;
	
	public function get_height():Int
	{
		return _height;
	}
	
	/**
	 * Returns the scale set in the engine.
	 * @return The scale.
	 */
	
	public var scale(get_scale, null):Int;
	
	public function get_scale():Int 
	{
		return _scale;
	}
	
	/**
	 * Returns the latest stats from the renderer.
	 * @return The stats.
	 */
	
	public var renderStats(get_renderStats, null):PxRenderStats;
	
	public function get_renderStats():PxRenderStats 
	{
		return _renderer.renderStats;
	}
	
	/**
	 * Returns the latest stats from the logic loop.
	 * @return The stats.
	 */
	
	public var logicStats(get_logicStats, null):PxLogicStats;
	
	public function get_logicStats():PxLogicStats 
	{
		return _logicStats;
	}
	
	/**
	 * Returns the latest stats from the current scene's collision manager.
	 * @return The stats.
	 */
	
	public var collisionStats(get_collisionStats, null):PxCollisionStats;
	
	public function get_collisionStats():PxCollisionStats 
	{
		return _currentScene.collisionManager.collisionStats;
	}
	
	/**
	 * Returns the current scene.
	 * @return The current scene or null if there is none.
	 */
	
	public var currentScene(get_currentScene, null):PxScene;
	
	public function get_currentScene():PxScene 
	{
		return _currentScene;
	}
	
	/**
	 * Decides wether to pause the application if focus is lost.
	 */
	
	public var pauseOnFocusLost(null, set_pauseOnFocusLost):Bool;
	
	public function set_pauseOnFocusLost(pPause:Bool):Bool 
	{
		_pauseOnFocusLost = pPause;
		return pPause;
	}
}