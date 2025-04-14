package engine.base.core;

import engine.base.entity.AbstractEngineEntityManager;
import engine.base.types.InputTypes.PlayerInputCommand;

enum abstract GameState(Int) {
	var PREPARING = 0;
	var PLAYING = 1;
	var WIN = 2;
    var LOSE = 3;
}

@:expose
abstract class BaseEngine {
	// Callbacks
	public var postLoopCallback:Void->Void;
	public var inputsProcessedCallback:Array<PlayerInputCommand>->Void;

	public final gameLoop:GameLoop;

    public var gameState = GameState.PREPARING;

	public var tick:Int;
	public var recentEngineLoopTime:Float;

	public final playerToEntityMap = new Map<String, String>();
	public var localPlayerId:String;

	private var hotInputCommands = new Array<PlayerInputCommand>();

	public var ticksSinceLastPop = 0;
	private final coldInputCommandsTreshhold = 10;
	private final coldInputCommands = new Array<PlayerInputCommand>();

	public function new() {
		gameLoop = new GameLoop(function loop(dt:Float, tick:Int) {
			this.tick = tick;

			if (ticksSinceLastPop == coldInputCommandsTreshhold) {
				ticksSinceLastPop = 0;
				coldInputCommands.shift();
			}
			ticksSinceLastPop++;

			engineLoopUpdate(dt);

			if (hotInputCommands.length > 0) {
				processInputCommands(hotInputCommands);
				inputsProcessedCallback(hotInputCommands);
				hotInputCommands = [];
			}

			if (postLoopCallback != null) {
				postLoopCallback();
			}
		});

		gameState = GameState.PLAYING;
	}

	// -----------------------------------
	// Abstract functions
	// -----------------------------------

	public abstract function processInputCommands(playerInputCommands:Array<PlayerInputCommand>):Void;

	public abstract function engineLoopUpdate(dt:Float):Void;

	public abstract function customDestroy():Void;

	// -----------------------------------
	// General
	// -----------------------------------

	public function destroy() {
		postLoopCallback = null;
		gameLoop.stopLoop();
		customDestroy();
	}
}
