package engine.impl.events.projectile;

import engine.impl.entity.base.projectile.EngineProjectileEntity;

interface CreateProjectileEventHandler {
	function createProjectileEventHandler(projectiles:Array<EngineProjectileEntity>):Void;
}

class CreateProjectileEventListener {

	public static final instance:CreateProjectileEventListener = new CreateProjectileEventListener();

	private function new() {}

	private final eventListeners = new List<CreateProjectileEventHandler>();

    public function subscribe(listener:CreateProjectileEventHandler) {
		eventListeners.add(listener);
	}

	public function unsubscribe(listener:CreateProjectileEventHandler) {
		eventListeners.remove(listener);
	}

	public function notify(projectiles:Array<EngineProjectileEntity>) {
		for (listener in eventListeners) {
			listener.createProjectileEventHandler(projectiles);
		}
	}
}