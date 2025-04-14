package game.base.entity;

import engine.base.entity.AbstractEngineEntity;

abstract class BasicGameEntity<T> extends h2d.Object {

    final engineEntity:T;

    public function new(parent:h2d.Object, engineEntity:T) {
        super(parent);

        this.engineEntity = engineEntity;
        
        final absEntity = cast(engineEntity, AbstractEngineEntity);
        setPosition(absEntity.getX(), absEntity.getY());
    }

    // ABS

    public abstract function update(dt:Float):Void;

    public abstract function debugDraw(graphics:h2d.Graphics):Void;

    // Getters

    public function getEngineEntity() {
        return engineEntity;
    }

}