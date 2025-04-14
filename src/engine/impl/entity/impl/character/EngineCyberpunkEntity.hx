package engine.impl.entity.impl.character;

import engine.base.types.EntityTypes.EntityType;

import engine.impl.entity.base.EngineEntityPrototype;
import engine.impl.entity.base.character.EngineCharacterEntity;
import engine.impl.types.CharacterTypes.CharacterEntity;

class EngineCyberpunkEntity extends EngineCharacterEntity implements EngineEntityPrototype<EngineCyberpunkEntity> {

    public function new() {
        final charcterEntity = new CharacterEntity({
            base: {
                x: 100,
                y: 100,
                entityType: EntityType.Cyberpunk,
                entityShape: {
                    width: 20,
                    height: 60,
                    rectOffsetX: 0,
                    rectOffsetY: 0,
                    radius: 0,
                },
                id: 'id',
                ownerId: 'id',
                rotation: 0,
                lookAtAngle: 0,
                aiControlled: false,
            },
            health:{
                health: 100,
            },
            movement: {
                inputDelay: 0.1000,
                speed: 300,
            },
            weapon: {
                shootInputDelay: 0.1000,
                lookAtInputDelay: 0.1000,
                damage: 5,
                burst: 1,
                range: 900,
                bulletSpeed: 130 * 10,
                spreadSteps: 10,
                spreadDecreaseMsDelay: 500 / 1000,
                spreadStepFactorDegree: 1,
            }
        });

        super(charcterEntity);
    }

    // ------------------------------------
	// Abstract implementation
	// ------------------------------------

    public function clone():EngineCyberpunkEntity {
        return new EngineCyberpunkEntity();
    }

}