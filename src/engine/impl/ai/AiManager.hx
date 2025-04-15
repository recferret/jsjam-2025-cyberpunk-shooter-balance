package engine.impl.ai;

import engine.base.MathUtils;

import haxe.Timer;

import engine.impl.events.ai.SpawnCharacterEventListener;
import engine.impl.entity.base.character.EngineCharacterEntity;

class AiManager {

    public static final CreepViewRadius = 300;
    public static final CreepTargetTrackingRadius = 500;

    public final aiSpawnPositions = [{x: 600, y: 200}];

    private final waveSpawnDelaySec = 10;
    public final waveMeleeCreeps = 1;
    public final waveRangeCreeps = 1;

    final aiCharacters = new Array<EngineCharacterEntity>();

    public function new() {
        Timer.delay(function callback() {
            // spawnAiCharacter();
        }, 1 * 1000);
    }

    public function assignCharacter(character:EngineCharacterEntity) {
        aiCharacters.push(character);
    }

    public function update(entities:Array<EngineCharacterEntity>) {
        for (character in aiCharacters) {
            for (entity in entities) {
                if (character.side != entity.side) {
                    final characterCenter = character.getBodyRectangle().getCenter();

                    if (character.target != null) {
                        // Has target
                        final targetCenter = character.target.getBodyRectangle().getCenter();
                        final distance = characterCenter.distance(targetCenter);

                        // Clear target if too far away
                        if (distance >= AiManager.CreepTargetTrackingRadius) {
                            character.target = null;
                        } else {
                            final targetAngle = MathUtils.angleBetweenPoints(characterCenter, targetCenter);
                            final attackMinDisatnce = AiManager.CreepViewRadius;
                            final isInAttackRange = distance <= attackMinDisatnce;

                            if (isInAttackRange) {
                                // Attack target
                                // creep.shoot(targetAngle);

                                // TODO produce input event here ?
                                character.lookAt(targetAngle);
                            } else {
                                // Move toward target
                                if (character.allowMovementInput()) {
                                    character.moveFreeAngle(targetAngle);
                                }
                            }

                            // Move toward target
                            if (distance > AiManager.CreepViewRadius) {

                            } else {
                                // Att
                            }
                        }
                    } else if (character.getBodyCircle().containsRect(entity.getBodyRectangle())) {
                        // Set target
                        character.target = entity;
                        trace('set target');
                    } else {
                        // No target, go to opposite base
                        final angleBetweenBase = MathUtils.angleBetweenPoints(characterCenter, GameEngine.LeftBaseRect.getCenter());
                        trace('No target, move to opposite base');

                        if (character.allowMovementInput()) {
                            character.moveFreeAngle(angleBetweenBase);
                        }
                    }
                }
            }
        }
    }

    private function spawnAiCharacter() {
        SpawnCharacterEventListener.instance.notify();
    }
}
