package engine.impl.entity.base.character;

import engine.base.entity.AbstractEngineEntity;
import engine.base.geom.Point;
import engine.base.types.EntityTypes.EntityType;
import engine.base.MathUtils;

import engine.impl.types.CharacterTypes.CharacterEntity;

class EngineCharacterEntity extends AbstractEngineEntity {

	public var target:EngineCharacterEntity;

	private final characterEntity:CharacterEntity;
	// TODO rmk to enum
	public var direction = 'right';
	private var lastLocalMovementInputCheck = 0.0;
	private var lastLocalLookAtInputCheck = 0.0;
	private var lastLocalShootInputCheck = 0.0;

	private var currentSpreadStep = 0;
	private var timeTillSpreadStepDecrease = 0.0;

    public function new(entity:CharacterEntity) {
        super(entity);

		this.characterEntity = cast(baseEntity, CharacterEntity);
		
		setSpeed(characterEntity.movement.speed);
    }

    // ------------------------------------
	// Abstract implementation
	// ------------------------------------

	public function absUpdate(dt:Float) {
		if (baseEntity.entityType == EntityType.Cyberpunk) {
			characterEntity.movement.speed = EngineDebugConfig.HeroSpeed;
			characterEntity.movement.inputDelay = EngineDebugConfig.HeroMoveDelay;

			characterEntity.weapon.spreadSteps = EngineDebugConfig.HeroSpreadSteps;
			characterEntity.weapon.spreadDecreaseMsDelay = EngineDebugConfig.HeroSpreadDecreaseMS;
			characterEntity.weapon.spreadStepFactorDegree = EngineDebugConfig.HeroSpreadAngleFactor;

			characterEntity.weapon.range = EngineDebugConfig.HeroWeaponRange;
			characterEntity.weapon.bulletSpeed = EngineDebugConfig.HeroWeaponBulletSpeed;

			EngineDebugConfig.CurrentHeroSpreadStep = currentSpreadStep;

			// currentSpreadStep += 1;
			// if (currentSpreadStep > characterEntity.weapon.spreadSteps) {
			// 	currentSpreadStep = characterEntity.weapon.spreadSteps;
			// }
			// timeTillSpreadStepDecrease = characterEntity.weapon.spreadDecreaseMsDelay;
		}

		if (currentSpreadStep > 0) {
			timeTillSpreadStepDecrease -= dt;
			if (timeTillSpreadStepDecrease < 0) {
				timeTillSpreadStepDecrease = 0;
			}
			if (timeTillSpreadStepDecrease == 0) {
				currentSpreadStep--;
				timeTillSpreadStepDecrease = characterEntity.weapon.spreadDecreaseMsDelay / 1000;
				if (currentSpreadStep < 0) {
					currentSpreadStep = 0;
				}
			}
		}

		// trace(currentSpreadStep, timeTillSpreadStepDecrease);
	}

	// ------------------------------------
	// Movement input
	// ------------------------------------

	public function move(angle:Float) {
		// final futurePos = getFuturePosition(1);

		var intersects = false;
		// if (Borders.instance.rectIntersectsWithBorder(getBodyRectangle())) {

		final deg = MathUtils.radsToDegree(MathUtils.normalizeAngle(angle));
		
		var allowHorizontalMovement = false;
		var allowVerticalMovement = false;

		var verticalDir = 'none';
		var horizontalDir = 'none';

		// Up
		if ((deg == 270 || deg == 315 || deg == 225)) {
		// if ((deg == 270 || deg == 315 || deg == 225) && futurePos.y - characterEntity.entityShape.height > 0) {
			allowVerticalMovement = true;
			verticalDir = 'up';
		}  
		// Down
		if ((deg == 90 || deg == 45 || deg == 135)) {
		// if ((deg == 90 || deg == 45 || deg == 135) && futurePos.y + characterEntity.entityShape.height / 2 < FswGameEngine.WorldHeight) {
			allowVerticalMovement = true;
			verticalDir = 'down';
		} 
		// Left
		if ((deg == 180 || deg == 135 || deg == 225)) {
		// if ((deg == 180 || deg == 135 || deg == 225) && futurePos.x - characterEntity.entityShape.width > 0) {
			allowHorizontalMovement = true;
			horizontalDir = 'left';
		}
		// Right
		if ((deg == 0 || deg == 315 || deg == 45)) {
		// if ((deg == 0 || deg == 315 || deg == 45) && futurePos.x + characterEntity.entityShape.width < FswGameEngine.WorldWidth) {
			allowHorizontalMovement = true;
			horizontalDir = 'right';
		}

		if (Borders.instance.rectIntersectsWithBorder(getFutureRectangle(2, angle))) {
			if (allowVerticalMovement) 
				allowVerticalMovement = false;
			if (allowHorizontalMovement) 
				allowHorizontalMovement = false;
		}

		if (allowHorizontalMovement) {
			baseEntity.x += characterEntity.movement.speed * Math.cos(angle) * lastDt;
		}
		if (allowVerticalMovement) {
			baseEntity.y += characterEntity.movement.speed * Math.sin(angle) * lastDt;
		}
	}

	public function moveFreeAngle(angle:Float) {
		baseEntity.x += characterEntity.movement.speed * Math.cos(angle) * lastDt;
		baseEntity.y += characterEntity.movement.speed * Math.sin(angle) * lastDt;
	}

	public function lookAt(angle:Float) {
		baseEntity.lookAtAngle = angle;

		final degAngle = MathUtils.radsToDegree(MathUtils.normalizeAngle(angle));

		if (degAngle >= 270 && degAngle <= 360 || degAngle >= 0 && degAngle <= 90) {
			direction = 'right';
		} else {
			direction = 'left';
		}
	}

	public function allowMovementInput() {
		final now = haxe.Timer.stamp();
		if (lastLocalMovementInputCheck == 0 || lastLocalMovementInputCheck + characterEntity.movement.inputDelay < now) {
			lastLocalMovementInputCheck = now;
			return true;
		} else {
			return false;
		}
	}

	// ------------------------------------
	// Action input
	// ------------------------------------

	public function shoot(angle:Float) {
		currentSpreadStep += 1;
		if (currentSpreadStep > characterEntity.weapon.spreadSteps) {
			currentSpreadStep = characterEntity.weapon.spreadSteps;
		}
		timeTillSpreadStepDecrease = characterEntity.weapon.spreadDecreaseMsDelay / 1000;
	}

	public function allowLookAtInput() {
		final now = haxe.Timer.stamp();
		if (lastLocalLookAtInputCheck == 0 || lastLocalLookAtInputCheck + characterEntity.weapon.lookAtInputDelay < now) {
			lastLocalLookAtInputCheck = now;
			return true;
		} else {
			return false;
		}
	}

	public function allowShootInput() {
		final now = haxe.Timer.stamp();
		if (lastLocalShootInputCheck == 0 || lastLocalShootInputCheck + characterEntity.weapon.shootInputDelay < now) {
			lastLocalShootInputCheck = now;
			return true;
		} else {
			return false;
		}
	}

	// -----------------------------------
	// Gun
	// -----------------------------------

	public function getGunBarrelPos() {
		final x = baseEntity.x;
		final y = baseEntity.y;
        var xx = x + 10;
        var yy = direction == 'right' ? y - 4 : y + 4;
		
		final lookAtAngle = MathUtils.radsToDegree(MathUtils.normalizeAngle(characterEntity.lookAtAngle));

		if (lookAtAngle > 280 && lookAtAngle < 350 ) {
			yy -= 4;
		}
		if (lookAtAngle > 280 && lookAtAngle < 320 ) {
			yy -= 8;
		}

		if (lookAtAngle > 8 && lookAtAngle < 40) {
			yy += 8;
		} else if (lookAtAngle > 8 && lookAtAngle < 60) {
			yy += 12;
		} else if (lookAtAngle > 8 && lookAtAngle < 90) {
			yy += 17;
		}

        final p = MathUtils.rotatePointAroundCenter(xx, yy, x, y, characterEntity.lookAtAngle);
        return new h2d.col.Point(p.x, p.y);
    }

	public function getGunSpread() {
		return MathUtils.degreeToRads(MathUtils.randomIntInRange(0, currentSpreadStep) * characterEntity.weapon.spreadStepFactorDegree);
	}

	// ------------------------------------
	// General
	// ------------------------------------

	// ------------------------------------
	// Getters
	// ------------------------------------

	// TODO generic ?
	public function getCharacterEntity() {
		return characterEntity;
	}

}