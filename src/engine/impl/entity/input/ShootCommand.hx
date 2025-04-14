package engine.impl.entity.input;

import engine.base.command.Command;

import engine.impl.entity.base.character.EngineCharacterEntity;

class ShootCommand implements Command<EngineCharacterEntity> {
    
    public function new() {
    }

    // ------------------------------------
	// Abstract implementation
	// ------------------------------------

    public function execute(characterEntity:EngineCharacterEntity, angle:Float) {
        characterEntity.shoot(angle);
    }
}