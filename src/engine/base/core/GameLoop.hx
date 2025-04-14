package engine.base.core;

abstract class Loop {
	public var delta = 0.0;

	private final targetFPSMillis:Int;
	private final updateCallback:Dynamic;

	private var tickCounter = 0;
	private var active = true;

	public function new(updateCallback:Dynamic) {
		this.updateCallback = updateCallback;
		targetFPSMillis = Math.floor(1000 / EngineConfig.TARGET_FPS);
		delta = 1 / targetFPSMillis;
	}

	public function tick() {
		#if js
		final start = getNowTime();
		updateCallback(delta / 1000, tickCounter);
		delta = (start + targetFPSMillis - getNowTime());
		#elseif (target.threaded)
		updateCallback(delta, tickCounter);
		#end
		tickCounter++;
	}

	public function stopLoop() {
		active = false;
	}

	private function getNowTime() {
		return haxe.Timer.stamp() * 1000;
	}
}

@:expose
class GameLoop {
	private final gameLoop:Loop;

	public function new(update:Dynamic) {
		#if js
		gameLoop = new DummyJsLoop(update);
		#elseif (target.threaded)
		gameLoop = new NativeLoop(update);
		#end
	}

	public function manualLoopUpdate() {
		gameLoop.tick();
	}

	public function stopLoop() {
		#if js
		gameLoop.stopLoop();
		#end
	}
}

class DummyJsLoop extends Loop {
	public function new(update:Dynamic) {
		super(update);
		loop();
	}

	private function loop() {
		if (active) {
			haxe.Timer.delay(loop, Std.int(delta));
			tick();
		}
	}
} 

class NativeLoop extends Loop {
	public function new(update:Dynamic) {
		super(update);
		#if (target.threaded)
		// while (active) {
		// 	tick();
		// 	Sys.sleep(delta / 1000);
		// }
		#end
	}
}
