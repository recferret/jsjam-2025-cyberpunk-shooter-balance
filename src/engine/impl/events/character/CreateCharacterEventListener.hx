package engine.impl.events.character;

import engine.impl.entity.base.character.EngineCharacterEntity;

interface CreateCharacterEventHandler {
	function createCharacterEventHandler(characters:Array<EngineCharacterEntity>):Void;
}

class CreateCharacterEventListener {

	public static final instance:CreateCharacterEventListener = new CreateCharacterEventListener();

	private function new() {}

	private final eventListeners = new List<CreateCharacterEventHandler>();

    public function subscribe(listener:CreateCharacterEventHandler) {
		eventListeners.add(listener);
	}

	public function unsubscribe(listener:CreateCharacterEventHandler) {
		eventListeners.remove(listener);
	}

	public function notify(characters:Array<EngineCharacterEntity>) {
		for (listener in eventListeners) {
			listener.createCharacterEventHandler(characters);
		}
	}
}