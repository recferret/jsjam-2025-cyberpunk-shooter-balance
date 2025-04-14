package game.base.scene;

import game.base.scene.AbstractScene;

abstract class AbstractSceneManager {
	private final sceneChangedCallback:AbstractScene->Void;
	private var currentScene:AbstractScene;
	
	public function new(sceneChangedCallback:AbstractScene->Void) {
		this.sceneChangedCallback = sceneChangedCallback;
	}

	// --------------------------------------
	// Impl
	// --------------------------------------

	public function notify(event:String, message:Dynamic) {
		if (currentScene != null) {
			currentScene = null;
		}
	}

	// --------------------------------------
	// Common
	// --------------------------------------

	public function startScene() {
		currentScene.start();
		changeSceneCallback();
	}

	public function getCurrentScene() {
		return currentScene;
	}

	public function onResize() {
		currentScene.onResize();
	}

	private function changeSceneCallback() {
		if (sceneChangedCallback != null) {
			sceneChangedCallback(currentScene);
		}
	}
}