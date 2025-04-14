package engine.impl.entity.manager;

import engine.base.entity.AbstractEngineEntityManager;
import engine.base.command.Command;

import engine.impl.entity.base.character.EngineCharacterEntity;
import engine.impl.entity.factory.character.CharacterFactory;
import engine.impl.entity.input.MoveCommand;
import engine.impl.entity.input.LookAtCommand;
import engine.impl.entity.input.ShootCommand;
import engine.impl.events.character.CreateCharacterEventListener;
import engine.impl.events.character.DeleteCharacterEventListener;

class CharacterEntityManager extends AbstractEngineEntityManager<CharacterFactory, EngineCharacterEntity> {

    private final moveCommand:Command<EngineCharacterEntity>;
    private final lookAtCommand:Command<EngineCharacterEntity>;
    private final shootCommand:Command<EngineCharacterEntity>;

    public function new() {
        super(8, new CharacterFactory());

        moveCommand = new MoveCommand();
        lookAtCommand = new LookAtCommand();
        shootCommand = new ShootCommand();
    }

    // ------------------------------------
	// Abstract implementation
	// ------------------------------------

    function initPool() {
        final cyberpunks = new haxe.ds.Vector(poolSize).map(f-> factory.createCyberpunk());

        addEntitiesToPool(cyberpunks.toArray());
    }

    function initiate(entity:EngineCharacterEntity) {
    }

    function entityUpdated(entity:EngineCharacterEntity) {
    }

    function entitiesCreated(entities:Array<EngineCharacterEntity>) {
        CreateCharacterEventListener.instance.notify(entities);
    }

    function entitiesDeleted(ids:Array<String>) {
        DeleteCharacterEventListener.instance.notify(ids);
    }

    // ------------------------------------
	// Input
	// ------------------------------------

    public function moveCharacterById(charId:String, angle:Float) {
        moveCommand.execute(getEntityById(charId), angle);
    }

    public function lookAtByCharacterId(charId:String, angle:Float) {
        lookAtCommand.execute(getEntityById(charId), angle);
    }

    public function shootByCharacterId(charId:String, angle:Float) {
        shootCommand.execute(getEntityById(charId), angle);
    }

}