package engine.impl.entity.base;

@:generic
interface EngineEntityPrototype<T> {
    function clone(): T;
}