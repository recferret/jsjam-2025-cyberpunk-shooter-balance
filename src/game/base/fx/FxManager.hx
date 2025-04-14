package game.base.fx;

import motion.Actuate;

import engine.base.MathUtils;

import game.impl.scene.impl.game.GameScene;
import game.impl.Colors;

class FxManager {

    public static final instance:FxManager = new FxManager();

    private var scene:h2d.Scene;

	private function new() {
    }

    public function setScene(scene:h2d.Scene) {
        this.scene = scene;
    }

    public function flint(x:Float, y:Float) {
        final bmp = new h2d.Bitmap(hxd.Res.flintandsteelneon.toTile().center());
        bmp.blendMode = Add;
        bmp.setPosition(x, y);
        bmp.setScale(1);
        bmp.color.set(1, 0, 0, 1);
        scene.add(bmp, 99);
    }

    public function light(x:Float, y:Float) {
        final bmp = new h2d.Bitmap(hxd.Res.light.toTile().center());
		bmp.blendMode = Add;
        bmp.setPosition(x, y);

        // Red
        bmp.color.set(1, 0, 0, 1);

        scene.add(bmp, 99);

        Actuate.tween(bmp, 0.3, {
            alpha: 0,
        }).onComplete(function callback() {
            bmp.remove();
        });

        Actuate.tween(bmp.color, 0.3, {
            x: 1,
            y: 0.8,
        })
        .onComplete(function callback() {
            bmp.remove();
        });
    }

    // It should be under the character
    public function muzzleFlash(x:Float, y:Float, r:Float, dir:String) {
        // Long flash
        final bmp = new h2d.Bitmap(hxd.Res.flash.toTile());
		bmp.blendMode = Add;
        bmp.tile.setCenterRatio(0, 0.5);
		bmp.scaleX = MathUtils.randomFloatInRange(1.5, 2);
		bmp.scaleY = MathUtils.randomFloatInRange(1.2, 1.4, true);
        bmp.setPosition(x, y);
        bmp.rotation = r;
        bmp.color.set(1, 0.714, 0, 1);
        scene.add(bmp, 99);

        Actuate.tween(bmp, 0.03, { alpha: 0 });
        Actuate.tween(bmp.color, 0.06, { x: 1, y: 0.29 })
        .onComplete(function callback() {
            bmp.remove();
        });

        // Core flash
        for(i in 0...6) {
            final bmp = new h2d.Bitmap(hxd.Res.flash.toTile());
            bmp.blendMode = Add;
            bmp.tile.setCenterRatio(0, 0.5);
            bmp.setPosition(x + MathUtils.randomFloatInRange(0, 1, true), y + MathUtils.randomFloatInRange(0, 1, true));
            bmp.rotation = r;
            bmp.alpha = MathUtils.randomFloatInRange(0.8, 1);
            bmp.scaleX = MathUtils.randomFloatInRange(0.7, 1.5);
            bmp.scaleY = MathUtils.randomFloatInRange(1.5, 2.5, true);
            bmp.color.set(0.075, 0.075, 0.071, 1);
            scene.add(bmp, 99);
            
            Actuate.tween(bmp, 0.03, { alpha: 0 });
            Actuate.tween(bmp.color, 0.06, { x: 1, y: 0.29 })
            .onComplete(function callback() {
                bmp.remove();
            });
            Actuate.tween(bmp.color, MathUtils.randomFloatInRange(0.03, 0.06), { })
            .onComplete(function callback() {
                bmp.remove();
            });
		}
    }

    public function flash(scene:h2d.Scene, color:Int, alpha:Float, ttl=0.1) {
		final bmp = new h2d.Bitmap(h2d.Tile.fromColor(color, 1, 1, alpha));
		bmp.blendMode = Add;
		bmp.scaleX = hxd.Window.getInstance().width;
		bmp.scaleY = hxd.Window.getInstance().height;

        scene.add(bmp, 99);

        Actuate.tween(bmp, ttl, {
            alpha: 0,
        }).onComplete(function callback() {
            bmp.remove();
        });
	}

    public function damageText(scene:h2d.Scene, x:Float, y:Float, damage:String) {
        final text = addText(scene, x, y - 60, damage);

       GameScene.SlideTweenManager.animateTo(text, 
            {   
                x: text.x + MathUtils.randomIntInRange(15, 40), 
                y: text.y - MathUtils.randomIntInRange(15, 100),
                alpha: 0,
            }, 
            MathUtils.randomFloatInRange(0.1, 0.5)
        ).start();
    }

    private function getFont() {
		return hxd.res.DefaultFont.get();
	}

	private function addText(parent:h2d.Object, x:Float, y:Float, text="") {
		var tf = new h2d.Text(getFont(), parent);
		tf.text = text;

        tf.textColor = Colors.RedColor;
        tf.dropShadow = { dx : 0.5, dy : 0.5, color : 0x8A783C, alpha : 0.8 };
        tf.setScale(4);
        tf.setPosition(x, y);

		return tf;
	}
}