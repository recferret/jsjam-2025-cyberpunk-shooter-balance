package engine.impl.entity.factory.projectile;

import engine.impl.entity.base.projectile.EngineProjectileEntity;
import engine.impl.entity.impl.projectile.EngineBulletEntity;

class ProjectileFactory implements AbstractProjectileFactory {
    private final shellSpawner:EntitySpawner<EngineBulletEntity>;

    public function new() {
        shellSpawner = new EntitySpawner<EngineBulletEntity>(new EngineBulletEntity());
    }

    public function createBullet():EngineProjectileEntity {
        return shellSpawner.spawnEntity();
    }

}