package engine.impl.entity.factory.character;

import engine.impl.entity.base.character.EngineCharacterEntity;
import engine.impl.entity.factory.character.AbstractCharacterFactory;
import engine.impl.entity.impl.character.EngineCyberpunkEntity;

class CharacterFactory implements AbstractCharacterFactory {
    private final cyberpunkSpawner:EntitySpawner<EngineCyberpunkEntity>;

    public function new() {
        cyberpunkSpawner = new EntitySpawner<EngineCyberpunkEntity>(new EngineCyberpunkEntity());
    }

    public function createCyberpunk():EngineCharacterEntity {
        return cyberpunkSpawner.spawnEntity();
    }
}