package engine.base.command;

@:generic
interface Command<T> {
    function execute(entity:T, angle:Float):Void;
}