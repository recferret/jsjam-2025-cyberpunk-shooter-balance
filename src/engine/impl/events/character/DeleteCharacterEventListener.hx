package engine.impl.events.character;

interface DeleteCharacterEventHandler {
	function deleteCharacterEventHandler(charactersIds:Array<String>):Void;
}

class DeleteCharacterEventListener {

	public static final instance:DeleteCharacterEventListener = new DeleteCharacterEventListener();

	private function new() {}

	private final eventListeners = new List<DeleteCharacterEventHandler>();

    public function subscribe(listener:DeleteCharacterEventHandler) {
		eventListeners.add(listener);
	}

	public function unsubscribe(listener:DeleteCharacterEventHandler) {
		eventListeners.remove(listener);
	}

	public function notify(characters:Array<String>) {
		for (listener in eventListeners) {
			listener.deleteCharacterEventHandler(characters);
		}
	}
}