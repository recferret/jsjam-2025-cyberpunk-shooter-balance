package game.impl.entity.projectile.impl;

import engine.impl.entity.base.projectile.EngineProjectileEntity;

import game.impl.entity.projectile.base.GameProjectileEntity;

class GameBulletEntity extends GameProjectileEntity {

    public function new(parent:h2d.Layers, fswProjectileEntity:EngineProjectileEntity) {
        super(parent, fswProjectileEntity);
        final bitmap = new h2d.Bitmap(hxd.Res.bullet.toTile().center(), this);
        bitmap.smooth = true;
        bitmap.color.set(1, 0.714, 0, 1);

        // var g = new h2d.Graphics(this);
        // g.beginFill(0xfed652, 0.3);
        // g.drawRect(-30, -1, 30, 2);
    }

}