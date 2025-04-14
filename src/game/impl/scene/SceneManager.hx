package game.impl.scene;

import game.base.scene.AbstractScene;
import game.base.scene.AbstractSceneManager;

import game.impl.scene.impl.test.FogOfWarTestScene;
import game.impl.scene.impl.test.GeomTestScene;
import game.impl.scene.impl.test.LevelEditorTestScene;
import game.impl.scene.impl.game.GameScene;

enum FswScene {
    FogOfWar;
    GeomTestScene;
	LevelEditorTestScene;
    GameScene;
} 

class SceneManager extends AbstractSceneManager {
	public function new(fswScene:FswScene, sceneChangedCallback:AbstractScene->Void) {
		super(sceneChangedCallback);

		switch (fswScene) {
			case FogOfWar:
				currentScene = new FogOfWarTestScene();
			case GeomTestScene:
				currentScene = new GeomTestScene();
			case LevelEditorTestScene:
				currentScene = new LevelEditorTestScene();
			case GameScene:
				currentScene = new GameScene();

			default:
		}

		startScene();
	}

}
