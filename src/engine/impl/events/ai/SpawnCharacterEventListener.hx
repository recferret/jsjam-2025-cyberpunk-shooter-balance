package engine.impl.events.ai;

interface SpawnCharacterEventHandler {
	function spawnCharacterEventHandler():Void;
}

class SpawnCharacterEventListener {

	public static final instance:SpawnCharacterEventListener = new SpawnCharacterEventListener();

	private function new() {}

	private final eventListeners = new List<SpawnCharacterEventHandler>();

    public function subscribe(listener:SpawnCharacterEventHandler) {
		eventListeners.add(listener);
	}

	public function unsubscribe(listener:SpawnCharacterEventHandler) {
		eventListeners.remove(listener);
	}

	public function notify() {
		for (listener in eventListeners) {
			listener.spawnCharacterEventHandler();
		}
	}
}