package engine.impl.entity.base.projectile;

import engine.base.MathUtils;
import engine.base.entity.AbstractEngineEntity;

import engine.impl.types.ProjectileTypes.ProjectileEntity;

class EngineProjectileEntity extends AbstractEngineEntity {

	public var maxDistanceTravelled = false;

	private final projectileEntity:ProjectileEntity;

	private var range = 0.0;
	private var distanceTravelled = 0.0;

    public function new(entity:ProjectileEntity) {
        super(entity);

		this.projectileEntity = cast(baseEntity, ProjectileEntity);
    }

	public function absUpdate(dt:Float) {
		if (!maxDistanceTravelled) {
			final dx = speed * Math.cos(projectileEntity.rotation) * lastDt;
			final dy = speed * Math.sin(projectileEntity.rotation) * lastDt;
			baseEntity.x += dx;
			baseEntity.y += dy;

			distanceTravelled += MathUtils.distanceTravelled(dx, dy);

			if (distanceTravelled > range) {
				maxDistanceTravelled = true;
			}
		}
	}

	// ------------------------------------
	// Getters
	// ------------------------------------

	public function getProjectileEntity() {
		return projectileEntity;
	}

	// ------------------------------------
	// Setters
	// ------------------------------------

	public function setRange(range:Int) {
		this.range = range;
	}
}