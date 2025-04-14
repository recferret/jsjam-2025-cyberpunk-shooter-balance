package engine.impl.entity.factory.projectile;

import engine.impl.entity.base.projectile.EngineProjectileEntity;

interface AbstractProjectileFactory {
    function createBullet(): EngineProjectileEntity;
}