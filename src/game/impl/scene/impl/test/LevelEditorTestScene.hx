package game.impl.scene.impl.test;

import game.base.graphics.BitmapUtils;
import game.base.graphics.TileUtils;
import h2d.Bitmap;
import game.base.graphics.GraphicsUtils;
import engine.base.geom.Rectangle;
import h3d.Engine;
import hxd.Event;
import hxd.Key;

import game.base.scene.AbstractScene;

class LevelEditorTestScene extends AbstractScene {

    private var lastMousePos:h2d.col.Point;
    private var allowToSpawnRect = true;

    private var rectToReplace:Bitmap;

	public function new() {
		super();

        scaleMode = ScaleMode.LetterBox(1280, 720);
        camera.setScale(2, 2);

        // BG
        final map1 = new h2d.Bitmap(hxd.Res.map1.toTile());
        final map2 = new h2d.Bitmap(hxd.Res.map2.toTile());
        final map3 = new h2d.Bitmap(hxd.Res.map3.toTile());
        final map4 = new h2d.Bitmap(hxd.Res.map4.toTile());

        map1.setPosition(0, 512);
        map2.setPosition(512, 512);
        map3.setPosition(512, 0);

        add(map1, AbstractScene.BG_LAYER);
        add(map2, AbstractScene.BG_LAYER);
        add(map3, AbstractScene.BG_LAYER);
        add(map4, AbstractScene.BG_LAYER);
    }


    public function absOnEvent(event:Event) {
        final cursor = new h2d.col.Point(event.relX, event.relY);
        camera.screenToCamera(cursor);
        lastMousePos = cursor;
    }

    public function absOnResize(w:Int, h:Int) {}

    public function absStart() {}

    public function absRender(e:Engine) {
    }

    public function absDestroy() {}

    public function absUpdate(dt:Float, fps:Float) {
        if (Key.isDown(Key.W)) {
            camera.y -= 5;
        }
        if (Key.isDown(Key.A)) {
            camera.x -= 5;
        }
        if (Key.isDown(Key.S)) {
            camera.y += 5;
        }
        if (Key.isDown(Key.D)) {
            camera.x += 5;
        }
        if (Key.isDown(Key.SPACE) && allowToSpawnRect) {
            allowToSpawnRect = false;

            final rect = BitmapUtils.createFromColoredTile(32, 32, Colors.RedColor);
            rect.setPosition(lastMousePos.x, lastMousePos.y);
            rect.alpha = 0.4;
            add(rect);
    
            final interaction = new h2d.Interactive(32, 32, rect);
            interaction.onPush = function(event:hxd.Event) {
                rectToReplace = rect;
            }
            interaction.onRelease = function(event:hxd.Event) {
                rectToReplace = null;
            }
            interaction.onClick = function(event:hxd.Event) {
                trace("click!");
            }

            haxe.Timer.delay(function callback() {
                allowToSpawnRect = true;
            }, 1000);
        }

        if (rectToReplace != null) {
            rectToReplace.setPosition(lastMousePos.x, lastMousePos.y);
        }
    }
}