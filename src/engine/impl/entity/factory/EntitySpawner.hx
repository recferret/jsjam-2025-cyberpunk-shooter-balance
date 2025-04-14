package engine.impl.entity.factory;

import engine.impl.entity.base.EngineEntityPrototype;

@:generic
class EntitySpawner<T> {

    private final entityPrototype:EngineEntityPrototype<T>;

    public function new(entityPrototype:EngineEntityPrototype<T>) {
        this.entityPrototype = entityPrototype;
    }

    public function spawnEntity() {
        return entityPrototype.clone();
    }

}