package engine.impl.types;

import haxe.Json;

import engine.base.types.EntityTypes.BaseEntity;
import engine.base.types.EntityTypes.BaseEntityStruct;

typedef CharacterHealthStruct = {
	health:Float,
}

typedef CharacterMovementStruct = {
	inputDelay:Float,
	speed:Float,
}

typedef CharacterWeaponStruct = {
	shootInputDelay:Float,
	lookAtInputDelay:Float,
	damage:Float,
	burst:Int,
	range:Int,
	bulletSpeed:Float,
	spreadSteps:Int,
	spreadDecreaseMsDelay:Float,
	spreadStepFactorDegree:Int,
}

typedef CharacterEntityStruct = {
    base:BaseEntityStruct,
    health:CharacterHealthStruct,
    movement:CharacterMovementStruct,
    weapon:CharacterWeaponStruct,
}

class CharacterEntity extends BaseEntity { 
	public var health:CharacterHealthStruct;
	public var movement:CharacterMovementStruct;
	public var weapon:CharacterWeaponStruct;

	public function new(struct:CharacterEntityStruct) {
		super(struct.base);

		this.health = struct.health;
		this.movement = struct.movement;
		this.weapon = struct.weapon;
	}

	public function toJson() {
		return Json.stringify({
			// Base entity
			x: x,
			y: y,
			entityType: entityType,
			entityShape: entityShape,
			id: id,
			ownerId: ownerId,
			rotation: rotation,
			lookAtAngle: lookAtAngle,

			// Specific
			health: health,
			movement: movement,
			weapon: weapon,
		});
	}
}