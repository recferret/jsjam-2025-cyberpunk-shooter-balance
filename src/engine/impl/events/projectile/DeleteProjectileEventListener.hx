package engine.impl.events.projectile;

interface DeleteProjectileEventHandler {
	function deleteProjectileEventHandler(ids:Array<String>):Void;
}

class DeleteProjectileEventListener {

	public static final instance:DeleteProjectileEventListener = new DeleteProjectileEventListener();

	private function new() {}

	private final eventListeners = new List<DeleteProjectileEventHandler>();

    public function subscribe(listener:DeleteProjectileEventHandler) {
		eventListeners.add(listener);
	}

	public function unsubscribe(listener:DeleteProjectileEventHandler) {
		eventListeners.remove(listener);
	}

	public function notify(ids:Array<String>) {
		for (listener in eventListeners) {
			listener.deleteProjectileEventHandler(ids);
		}
	}
}