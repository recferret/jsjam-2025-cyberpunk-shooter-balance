package game.impl.entity.projectile;

import engine.impl.entity.base.projectile.EngineProjectileEntity;

import game.impl.entity.projectile.base.GameProjectileEntity;
import game.impl.entity.projectile.impl.GameBulletEntity;

class GameProjectileFactory {

    public function new() {
    }

    public function createProjectile(parent:h2d.Layers, projectileEntity:EngineProjectileEntity):GameProjectileEntity {
        switch (projectileEntity.getEntityType()) {
            case Bullet:
                return new GameBulletEntity(parent, projectileEntity); 
            default:
                return null;
        }
    }

}