package game.impl.entity.character.base;

import h2d.Tile;
import h2d.Graphics;

import hxd.Math;

import engine.base.geom.Point;
import engine.base.geom.Rectangle;
import engine.base.Cooldown;
import engine.base.MathUtils;

import engine.impl.entity.base.character.EngineCharacterEntity;

import game.base.entity.BasicGameEntity;
import game.base.graphics.GraphicsUtils;
import game.base.scene.AbstractScene;

import game.impl.scene.impl.game.GameScene;

abstract class GameCharacterEntity extends BasicGameEntity<EngineCharacterEntity> {

    public final idleTiles = new Array<Tile>();
    public final runTiles = new Array<Tile>();
    public final deathTiles = new Array<Tile>();

    private var gun:h2d.Bitmap;

    public var isMoving = false;
    public var animation:h2d.Anim;

    // private var gun:h2d.Graphics;
    private var baseColor = new h3d.Vector();
    private var blinkColor = new h3d.Vector();
    private var phantomColor = new h3d.Vector();

    // MOVE ftime to abstraction and rename
    private var ftime = 1;
    private var dir = -1;
    private var gunFlipped = false;

    public function new(parent:h2d.Layers, characterEntity:EngineCharacterEntity) {
        super(parent, characterEntity);

        animation = new h2d.Anim();
        animation.colorAdd = new h3d.Vector();

        addChild(animation);
        parent.add(this, AbstractScene.CHARACTER_LAYER);
    }

    private function setObjectDirection() {
        final lookAngleDegree = MathUtils.radsToDegree(engineEntity.getLookAtAngle());
        var newDir = 0;
        if (lookAngleDegree > -90 && lookAngleDegree < 90) {
            newDir = 1;
        } else {
            newDir = -1;
        }
        if (dir != newDir) {
            dir = newDir;

            if (gun != null) {
                if (dir == -1) {
                    gun.scaleY = -1 * gun.scaleY;
                    animation.scaleX = -1 * animation.scaleX;
                    gunFlipped = true;
                }

                if (dir == 1 && gunFlipped) {
                    gun.scaleY = -1 * gun.scaleY;
                    animation.scaleX = -1 * animation.scaleX;
                    gunFlipped = false;
                }
            }
        }
    }

    private var currentAnimation = 'idle';

    public function setIdleAnimationState(forced = false) {
        if (forced || (currentAnimation == 'moving' && !isMoving)) {
            currentAnimation = 'idle';
            animation.play(idleTiles);
            animation.speed = 4;
        }
    }

    public function setRunAnimationState(forced = false) {
        if (forced || (currentAnimation == 'idle' && isMoving)) {
            currentAnimation = 'moving';
            animation.play(runTiles);
            animation.speed = 8;
        }
    }

    public function update(dt:Float) {
        setPosition(
            Math.lerp(x, engineEntity.getX(), 0.1),
            Math.lerp(y, engineEntity.getY(), 0.1),
        );
        rotation = engineEntity.getRotation();

        setObjectDirection();

        final clientPos = new Point(x, y);
        final serverPos = new Point(engineEntity.getX(), engineEntity.getY());
        final dist = Std.int(clientPos.distance(serverPos));
        isMoving = dist > 5;

        setIdleAnimationState();
        setRunAnimationState();

        // animation.play(runTiles);
        // 

        if (gun != null) {

            gun.x = dir == 1 ? -10 : 10;
            gun.y = 0;

            final clientPos = new Point(x, y);
            final serverPos = new Point(engineEntity.getX(), engineEntity.getY());
            final dist = Std.int(clientPos.distance(serverPos));
            isMoving = dist > 0;

            gun.x += isMoving ? -2 + Math.cos(ftime * 0.2) * 3 : 0;
            gun.y += Math.sin(0.2 + ftime * 0.3) * (isMoving ? 1 : 0.5);

            gun.rotation = engineEntity.getLookAtAngle();

            final recoil = Cooldown.instance.get('gun_recoil_' + engineEntity.getId());
            if (recoil != null) {
                if (dir == 1) {
                    gun.rotation -= 0.09 * recoil.completionRatio;
                    gun.x -= 4 * recoil.completionRatio;
                    gun.y -= 2;
                } else {
                    gun.rotation += 0.09 * recoil.completionRatio;
                    gun.x += 4 * recoil.completionRatio;
                    gun.y += 2;
                }
            }
        }

        final blink = Cooldown.instance.get('character_blink_' + engineEntity.getId());
        if (blink == null) {
			blinkColor.r *= Math.pow(0.60, 1);
			blinkColor.g *= Math.pow(0.55, 1);
			blinkColor.b *= Math.pow(0.50, 1);
		}

        final phantom = Cooldown.instance.get('character_phantom_' + engineEntity.getId());
        if (phantom == null) {
			phantomColor.r *= Math.pow(0.60, 1);
			phantomColor.g *= Math.pow(0.55, 1);
			phantomColor.b *= Math.pow(0.50, 1);
		}

        if (animation != null) {
            animation.colorAdd.add(baseColor);

            animation.colorAdd.r = blinkColor.r;
            animation.colorAdd.g = blinkColor.g;
            animation.colorAdd.b = blinkColor.b;

            animation.colorAdd.r += phantomColor.r;
            animation.colorAdd.g += phantomColor.g;
            animation.colorAdd.b += phantomColor.b;
        }

        if (gun != null) {
            gun.colorAdd.add(baseColor);

            gun.colorAdd.r = blinkColor.r;
            gun.colorAdd.g = blinkColor.g;
            gun.colorAdd.b = blinkColor.b;

            gun.colorAdd.r += phantomColor.r;
            gun.colorAdd.g += phantomColor.g;
            gun.colorAdd.b += phantomColor.b;
        }

        ftime++;
    }

    public function addGun() {
        gun = new h2d.Bitmap(hxd.Res.weapon.toTile(), this);
        gun.tile.setCenterRatio(0.4, 0.5);
        gun.colorAdd = new h3d.Vector();
    }

    public function gunRecoil() {
        x += -dir * MathUtils.randomIntInRange(1, 4);
    }

    public function drawSight(graphics:Graphics) {
        final line = engineEntity.getLookingAtLine(engineEntity.getCharacterEntity().weapon.range);
        GraphicsUtils.DrawLine(graphics, 
            line.x1,
            line.y1,
            line.x2,
            line.y2,
            Colors.RedColor
        );
    }

    public function debugDraw(graphics:Graphics) {
        GraphicsUtils.DrawRect(graphics, 
            new Rectangle(
                engineEntity.getBodyRectangle().x,
                engineEntity.getBodyRectangle().y,
                engineEntity.getBodyRectangle().w,
                engineEntity.getBodyRectangle().h,

                // engineEntity.getEchoBody().x,
                // engineEntity.getEchoBody().y,
                // engineEntity.getEchoBody().bounds().width,
                // engineEntity.getEchoBody().bounds().height,
                rotation
            ), 
            Colors.BlueColor
        );

        GraphicsUtils.DrawCircle(graphics, engineEntity.getBodyCircle(), Colors.BlueColor);

        final gunPos = engineEntity.getGunBarrelPos();
        GraphicsUtils.DrawRect(graphics, new Rectangle(gunPos.x, gunPos.y, 5, 5, 0), Colors.RedColor);
    }

    // FX

    public function squashFx() {
        final squashIn = GameScene.SlideTweenManager.animateTo(this, { scaleX: 0.55, scaleY: 0.60 }, 0.05);
        final squashOut = GameScene.SlideTweenManager.animateTo(this, { scaleX: 0.5, scaleY: 0.5 }, 0.05);

        GameScene.SlideTweenManager.sequence([squashIn, squashOut]).start();
    }

    public function blinkFx() {
        blinkColor.setColor(0xff0000);

        Cooldown.instance.add({
            name: 'character_blink_' + engineEntity.getId(),
            durationSeconds: 0.06,
            onCompleteDelete: true,
        });
    }

    public function phantomFx() {
        phantomColor.setColor(0x0000FF);

        Cooldown.instance.add({
            name: 'character_phantom_' + engineEntity.getId(),
            durationSeconds: 1,
            onCompleteDelete: true,
        });

        final alphaIn = GameScene.SlideTweenManager.animateTo(this, { alpha: 1 }, 0.5);
        final alphaOut = GameScene.SlideTweenManager.animateTo(this, { alpha: 0 }, 0.5);

        GameScene.SlideTweenManager.sequence([alphaIn, alphaOut]).start();
    }

}