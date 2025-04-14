package game.impl.scene;

import game.base.scene.AbstractScene;
import game.base.scene.AbstractSceneManager;

import game.impl.scene.impl.game.GameScene;
import game.impl.scene.impl.test.FogOfWarTestScene;
import game.impl.scene.impl.test.GeomTestScene;

enum FswScene {
    FogOfWar;
    GameScene;
    GeomTestScene;
} 

class SceneManager extends AbstractSceneManager {
	public function new(fswScene:FswScene, sceneChangedCallback:AbstractScene->Void) {
		super(sceneChangedCallback);

		switch (fswScene) {
			case FogOfWar:
				currentScene = new FogOfWarTestScene();
			case GameScene:
				currentScene = new GameScene();
			case GeomTestScene:
				currentScene = new GeomTestScene();
			default:
		}

		startScene();
	}

}
