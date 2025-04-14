package game.base.camera;

import hxd.Window;

import engine.base.Cooldown;

class CameraController {
 
    private final scene:h2d.Scene;

    private var target:h2d.Object;

    private var bumpOffX = 0.0;
	private var bumpOffY = 0.0;
	private var bumpFrict = 0.85;

	private var shakePower = 1.0;

    public function new(scene:h2d.Scene) {
        this.scene = scene;
    }

    public function setTarget(target:h2d.Object) {
        this.target = target;
    }

    public function bump(x:Float, y:Float) {
        bumpOffX += x;
		bumpOffY += y;
    }

    public function shakeS(t:Float, shakePower:Float = 1.0) {
        Cooldown.instance.add({
            name: 'camera_shaking',
            durationSeconds: t,
            onCompleteDelete: true,
        });
		this.shakePower = shakePower;
	}

    // TODO pass dt and frames passed ?
    private var framesPassed = 0;
    public function update() {
        if (target != null) {
            scene.camera.x = hxd.Math.lerp(scene.camera.x, target.x - 640, 0.1);
            if (scene.camera.x < 0) {
                scene.camera.x = 0;
            }
            if (scene.camera.x > 1280) {
                scene.camera.x = 1280   ;
            }

            scene.camera.y = hxd.Math.lerp(scene.camera.y, target.y - 360, 0.1);
            if (scene.camera.y < 35) {
                scene.camera.y = 35;
            }
            if (scene.camera.y > 1800) {
                scene.camera.y = 1800;
            }

            scene.x = 0;
            scene.y = 0;
        }

        // Bumps friction
		bumpOffX *= hxd.Math.pow(bumpFrict, 1.0);
		bumpOffY *= hxd.Math.pow(bumpFrict, 1.0);

		// Bump
		scene.x -= bumpOffX;
		scene.y -= bumpOffY;

		if (Cooldown.instance.has("camera_shaking") ) {
			final shakeCompletionRatio = Cooldown.instance.get('camera_shaking').completionRatio;
            scene.x += Math.cos(framesPassed * 1.1) * 2.5 * shakePower * shakeCompletionRatio;
			scene.y += Math.sin(0.3 + framesPassed * 1.7) * 2.5 * shakePower * shakeCompletionRatio;
		}

        scene.x = Math.round(scene.x);
		scene.y = Math.round(scene.y);

        framesPassed++;
    }
}