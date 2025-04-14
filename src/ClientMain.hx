import engine.base.Cooldown;

import game.base.scene.AbstractScene;
import game.impl.scene.SceneManager;

class ClientMain extends hxd.App {

    private var sceneManager:SceneManager;

    override function init() {
        engine.backgroundColor = 0xB0B0B0;

        sceneManager = new SceneManager(
            FswScene.GameScene, 
            function callback(scene:AbstractScene) {
                setScene2D(scene);
                sevents.addScene(scene.getInputScene());
            }
        );
    }

    override function update(dt:Float) {
		if (sceneManager != null && sceneManager.getCurrentScene() != null) {
			Cooldown.instance.update(dt);
            sceneManager.getCurrentScene().update(dt, engine.fps);
		}
	}

	override function onResize() {
		if (sceneManager != null) {
			sceneManager.onResize();
		}
	}

    static function main() {
        hxd.Res.initEmbed();
        new ClientMain();
    }
}