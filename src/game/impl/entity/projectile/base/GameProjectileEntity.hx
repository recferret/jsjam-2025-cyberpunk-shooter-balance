package game.impl.entity.projectile.base;

import h2d.Graphics;
import h2d.Layers;
import hxd.Math;

import engine.impl.entity.base.projectile.EngineProjectileEntity;

import game.base.entity.BasicGameEntity;
import game.base.scene.AbstractScene;

abstract class GameProjectileEntity extends BasicGameEntity<EngineProjectileEntity> {

    public function new(parent:Layers, projectileEntity:EngineProjectileEntity) {
        super(parent, projectileEntity);

        parent.add(this, AbstractScene.UNDER_CHARACTER_LAYER);
    }

    public function update(dt:Float) {
        setPosition(
            Math.lerp(x, engineEntity.getX(), 0.3),
            Math.lerp(y, engineEntity.getY(), 0.3),
        );
        rotation = engineEntity.getRotation();
    }

    public function debugDraw(graphics:Graphics) {
    }

}