package game.base.scene;

import h2d.Object;
import h3d.Engine;
import hxd.Event.EventKind;

import engine.base.types.InputTypes.PlayerInputCommand;

import game.base.input.Input;

typedef BasicSceneClickCallback = {
	x:Float,
	y:Float,
	eventKind:EventKind,
} 

abstract class AbstractScene extends h2d.Scene {

	public static final DEBUG_GRAPHICS_LAYER:Int = 99;
    public static final BG_LAYER:Int = 0;
    public static final UNDER_CHARACTER_LAYER:Int = 9;
    public static final CHARACTER_LAYER:Int = 10;


	public var debugGraphics:h2d.Graphics;
	public var uiScene:h2d.Scene;

	private var basicSceneCallback:BasicSceneClickCallback->Void;
	private var _input:Input;
	private var localPlayerId:String;

	public function new() {
		super();

		debugGraphics = new h2d.Graphics();
		add(debugGraphics, DEBUG_GRAPHICS_LAYER);

		hxd.Window.getInstance().addEventTarget(function onEvent(event:hxd.Event) {
			absOnEvent(event);
		});

		onResize();
	}

	// ------------------------------------
	// Abstraction
	// ------------------------------------

	public abstract function absOnEvent(event:hxd.Event):Void;
	public abstract function absOnResize(w:Int, h:Int):Void;
	public abstract function absStart():Void;
	public abstract function absRender(e:Engine):Void;
	public abstract function absDestroy():Void;
	public abstract function absUpdate(dt:Float, fps:Float):Void;

	// ------------------------------------
	// General
	// ------------------------------------

	public function setInputCallback(inputCallback:PlayerInputCommand->Void) {
		if (_input == null) {
			_input = new Input(inputCallback);
		}
	}

	public function setBasicSceneCallback(basicSceneCallback:BasicSceneClickCallback->Void) {
		this.basicSceneCallback = basicSceneCallback;
	}

	public function setUiScene(scene:h2d.Scene) {
		uiScene = scene;
	}

	public function start() {
		absStart();
	}

	public function onResize() {
		final w = 1280;
		final h = 720;

		// scaleMode = ScaleMode.Stretch(w, h);

		absOnResize(w, h);
	}

	public function update(dt:Float, fps:Float) {
		debugGraphics.clear();

		if (_input != null) {
			_input.updateKeyboardInput();
		}

		absUpdate(dt, fps);
	}

	public override function render(e:Engine) {
		absRender(e);
		super.render(e);
		if (uiScene != null) {
			uiScene.render(e);
		}
	}

	// ------------------------------------
	// Getters
	// ------------------------------------

	public function getInputScene() {
		return uiScene != null ? uiScene : this;
	}

	// ------------------------------------
	// Setters
	// ------------------------------------

}