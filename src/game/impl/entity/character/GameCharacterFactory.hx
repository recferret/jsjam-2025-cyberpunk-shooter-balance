package game.impl.entity.character;

import h2d.Scene;

import engine.impl.entity.base.character.EngineCharacterEntity;

import game.impl.entity.character.base.GameCharacterEntity;
import game.impl.entity.character.impl.GameCyberpunkEntity;

class GameCharacterFactory {

    public function new() {
    }

    public function createCharacter(parent:Scene, characterEntity:EngineCharacterEntity):GameCharacterEntity {
        switch (characterEntity.getEntityType()) {
            case Cyberpunk:
                return new GameCyberpunkEntity(parent, characterEntity);
            default:
                return null;
        }
    }

}