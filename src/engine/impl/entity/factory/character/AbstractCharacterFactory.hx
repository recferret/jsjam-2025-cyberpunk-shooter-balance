package engine.impl.entity.factory.character;

import engine.impl.entity.base.character.EngineCharacterEntity;

interface AbstractCharacterFactory {
    function createCyberpunk(): EngineCharacterEntity;
}