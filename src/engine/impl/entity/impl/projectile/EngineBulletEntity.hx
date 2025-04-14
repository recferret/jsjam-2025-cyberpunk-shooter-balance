package engine.impl.entity.impl.projectile;

import engine.base.types.EntityTypes.EntityType;

import engine.impl.entity.base.EngineEntityPrototype;
import engine.impl.entity.base.projectile.EngineProjectileEntity;
import engine.impl.types.ProjectileTypes.ProjectileEntity;

class EngineBulletEntity extends EngineProjectileEntity implements EngineEntityPrototype<EngineBulletEntity> {

    public function new() {
        final projectileEntity = new ProjectileEntity({
            base: {
                x: 100,
                y: 100,
                entityType: EntityType.Bullet,
                entityShape: {
                    width: 5,
                    height: 5,
                    rectOffsetX: 0,
                    rectOffsetY: 0,
                    radius: 0,
                },
                id: 'id',
                ownerId: 'id',
                rotation: 0,
                lookAtAngle: 0,
                aiControlled: false,
            },
            // general:{
            //     damage: 1,
            //     speed: 20,
            //     range: 1000,
            // },
        });

        super(projectileEntity);
    }

    // ------------------------------------
	// Abstract implementation
	// ------------------------------------

    public function clone():EngineBulletEntity {
        return new EngineBulletEntity();
    }

}