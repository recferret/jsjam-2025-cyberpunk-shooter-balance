package engine.impl.entity.manager;

import engine.base.entity.AbstractEngineEntityManager;

import engine.impl.entity.base.projectile.EngineProjectileEntity;
import engine.impl.entity.factory.projectile.ProjectileFactory;
import engine.impl.events.projectile.CreateProjectileEventListener;
import engine.impl.events.projectile.DeleteProjectileEventListener;

class ProjectileEntityManager extends AbstractEngineEntityManager<ProjectileFactory, EngineProjectileEntity> {

    public function new() {
        super(1000, new ProjectileFactory());
    }

    // ------------------------------------
	// Abstract implementation
	// ------------------------------------

    function initPool() {
        final shells = new haxe.ds.Vector(poolSize).map(f-> factory.createBullet());

        addEntitiesToPool(shells.toArray());
    }

    function initiate(entity:EngineProjectileEntity) {
    }

    function entityUpdated(entity:EngineProjectileEntity) {
        if (entity.maxDistanceTravelled) {
            deactivateAndPrepareToDelete(entity.getId());
        }
    }

    function entitiesCreated(entities:Array<EngineProjectileEntity>) {
        CreateProjectileEventListener.instance.notify(entities);
    }

    function entitiesDeleted(ids:Array<String>) {
        DeleteProjectileEventListener.instance.notify(ids);
    }

}