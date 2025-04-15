package engine.impl.entity.base.projectile;

import engine.base.MathUtils;
import engine.base.entity.AbstractEngineEntity;

import engine.impl.types.ProjectileTypes.ProjectileEntity;

class EngineProjectileEntity extends AbstractEngineEntity {

	public var destroyProjectile = false;

	private final projectileEntity:ProjectileEntity;

	private var range = 0.0;
	private var distanceTravelled = 0.0;

    public function new(entity:ProjectileEntity) {
        super(entity);

		this.projectileEntity = cast(baseEntity, ProjectileEntity);
    }

	public function absUpdate(dt:Float) {
		if (!destroyProjectile && Borders.instance.rectIntersectsWithBorder(getBodyRectangle())) {
			destroyProjectile = true;
		}

		if (!destroyProjectile) {
			final dx = speed * Math.cos(projectileEntity.rotation) * lastDt;
			final dy = speed * Math.sin(projectileEntity.rotation) * lastDt;
			baseEntity.x += dx;
			baseEntity.y += dy;

			distanceTravelled += MathUtils.distanceTravelled(dx, dy);

			if (distanceTravelled > range) {
				destroyProjectile = true;
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