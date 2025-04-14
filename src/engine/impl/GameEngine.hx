package engine.impl;

import uuid.Uuid;

import engine.base.geom.Rectangle;
import engine.base.core.BaseEngine;

import engine.base.types.EntityTypes.EntityMinDetails;
import engine.base.types.EntityTypes.EntityType;
import engine.base.types.InputTypes.InputCommand;
import engine.base.types.InputTypes.PlayerInputCommand;
import engine.base.MathUtils;

import engine.impl.ai.AiManager;

import engine.impl.entity.base.character.EngineCharacterEntity;
import engine.impl.entity.base.projectile.EngineProjectileEntity;

import engine.impl.entity.manager.CharacterEntityManager;
import engine.impl.entity.manager.ProjectileEntityManager;

import engine.impl.events.ai.SpawnCharacterEventListener;
import engine.impl.events.character.CreateCharacterEventListener;
import engine.impl.events.projectile.CreateProjectileEventListener;
import engine.impl.events.projectile.DeleteProjectileEventListener;

import engine.impl.types.CharacterTypes.CharacterEntity;

typedef ProjectileHit = {
	projectile:EngineProjectileEntity,
	character:EngineCharacterEntity,
} 

@:expose
class GameEngine
	extends BaseEngine
	implements CreateCharacterEventHandler
	implements CreateProjectileEventHandler 
	implements DeleteProjectileEventHandler
	implements SpawnCharacterEventHandler {

	public static final WorldWidth = 2560;
	public static final WorldHeight = 2560;
	public static final LeftBaseRect = new Rectangle(100, 2250, 200, 200, 0);
	public static final RightBaseRect = new Rectangle(2250, 150, 200, 200, 0);

	// TODO callbacks or events ?
	private var postUpdateCallback:Void->Void;
	private var projectileHitCallback:Array<ProjectileHit>->Void;

	// Entity managers
	private final characterEntityManager:CharacterEntityManager;
	private final projectileEntityManager:ProjectileEntityManager;

	private final aiManager:AiManager;

    public static function main() {}

    public function new() {
        super();

		characterEntityManager = new CharacterEntityManager();
		projectileEntityManager = new ProjectileEntityManager();

		CreateCharacterEventListener.instance.subscribe(this);
		CreateProjectileEventListener.instance.subscribe(this);
		DeleteProjectileEventListener.instance.subscribe(this);

		SpawnCharacterEventListener.instance.subscribe(this);

		// Add AI manager
		aiManager = new AiManager();

		gameState = GameState.PLAYING;
    }

	// ------------------------------------
	// Entity events
	// ------------------------------------

	public function createCharacterEventHandler(characters:Array<EngineCharacterEntity>) {
		for (character in characters) {
			characterEntityManager.initiateEntity(character);

			if (character.aiControlled) {
				aiManager.assignCharacter(character);
			} else {
				playerToEntityMap.set(character.getOwnerId(), character.getId());
			}
		}
	}

	public function createProjectileEventHandler(projectiles:Array<EngineProjectileEntity>) {
		for (projectile in projectiles) {
			final character = characterEntityManager.getEntityByOwner(projectile.getOwnerId());
			projectile.setSpeed(character.getCharacterEntity().weapon.bulletSpeed);
			projectile.setRange(character.getCharacterEntity().weapon.range);

			projectileEntityManager.initiateEntity(projectile);
		}
	}

	public function deleteProjectileEventHandler(ids:Array<String>) {
	}

	// Ai events

	public function spawnCharacterEventHandler() {
		createCharacter({
			x: 600,
			y: 200,
			entityType: EntityType.Cyberpunk,
			ownerId: Uuid.short(),
			aiControlled: true,
		});
	
	}

    // ------------------------------------
	// Abstract implementation
	// ------------------------------------

    public function engineLoopUpdate(dt:Float) {
		if (gameState == GameState.PLAYING) {
			characterEntityManager.deleteMarkedEntities();
			characterEntityManager.createMarkedEntities();

			projectileEntityManager.deleteMarkedEntities();
			projectileEntityManager.createMarkedEntities();

			characterEntityManager.update(dt);
			projectileEntityManager.update(dt);

			// Enable or disable, add to config
			aiManager.update(characterEntityManager.getActiveEntities());

			final projectilesToDelete = new Array<String>();
			final projectilesHit = new Array<ProjectileHit>();

			for (projectile in projectileEntityManager.getActiveEntities()) {
				if (!projectilesToDelete.contains(projectile.getId())) {
					for (character in characterEntityManager.getActiveEntities()) {
						if (projectile.getOwnerId() != character.getOwnerId()) {
							if (projectile.getBodyRectangle().containsRect(character.getBodyRectangle())) {
								projectilesToDelete.push(projectile.getId());
								projectilesHit.push({
									projectile: projectile,
									character: character,
								});
								break;
							}
						}
					}
				}
			}

			for (projectile in projectilesToDelete) {
				projectileEntityManager.deactivateAndPrepareToDelete(projectile);
			}

			if (postUpdateCallback != null) {
				postUpdateCallback();
			}

			if (projectileHitCallback != null && projectilesHit.length > 0) {
				projectileHitCallback(projectilesHit);
			}
		}
    }

    public function processInputCommands(playerInputCommands:Array<PlayerInputCommand>) {
		for (input in playerInputCommands) {
			final character = characterEntityManager.getEntityById(playerToEntityMap.get(input.playerId));
			if (character != null) {
				switch (input.inputCommand) {
					case Skill:
					case LookAt:
						characterEntityManager.lookAtByCharacterId(character.getId(), input.angle);
					case Move:
						characterEntityManager.moveCharacterById(character.getId(), input.angle);
					case Shoot:
						final barelPos = character.getGunBarrelPos();
						final positiveOrNot = MathUtils.randomIntInRange(1, 2);
						final spread = character.getGunSpread();
						final shootAngle = character.getLookAtAngle() + (positiveOrNot == 1 ? spread : -spread);
						projectileEntityManager.assignEntityToOwnerAndActivate({
							ownerId: character.getOwnerId(),
							entityType: EntityType.Bullet,
							x: barelPos.x,
							y: barelPos.y,
							rotation: shootAngle,
						});
						characterEntityManager.shootByCharacterId(character.getId(), character.getLookAtAngle());
				}
			} else {
				trace('processInputCommands error');
			}
		}
	}

    public function customDestroy() {}

	// ------------------------------------
	// Entity 
	// ------------------------------------

	public function getCharacterByOnwerId(ownerId:String) {
		return characterEntityManager.getEntityByOwner(ownerId);
	}

	public function getCharacterEntitiesByOwnerIds(ownerIds:Array<String>) {
		final characters = new Array<CharacterEntity>();
		for (ownerId in ownerIds) {
			characters.push(characterEntityManager.getEntityByOwner(ownerId).getCharacterEntity());
		}
		return characters;
	}

	public function getCharacterEntities() {
		return characterEntityManager.getEntities().filter(f -> f.isInitiatedAndActive());
	}

	public function createCharacter(entityMinDetails:EntityMinDetails) {
		characterEntityManager.assignEntityToOwnerAndActivate(entityMinDetails);
	}

	public function deleteCharacterById(id:String) {
		characterEntityManager.deactivateAndPrepareToDelete(id);
	}

	public function deleteCharacterByOwnerId(ownerId:String) {
		final character = characterEntityManager.getEntityByOwner(ownerId);
		characterEntityManager.deactivateAndPrepareToDelete(character.getId());
	}

	// ------------------------------------
	// Input
	// ------------------------------------

	public function addInputCommand(input:PlayerInputCommand, checkInput = true) {
		final character = characterEntityManager.getEntityById(playerToEntityMap.get(input.playerId));
		var allow = true;

		if (checkInput) {
			if (input.inputCommand == InputCommand.Shoot) {
				if (!character.allowShootInput()) {
					allow = false;
				}
			} else if (input.inputCommand == InputCommand.LookAt) {
				if (!character.allowLookAtInput()) {
					allow = false;
				}
			} else {
				if (!character.allowMovementInput()) {
					allow = false;
				}
			}
		}

		if (allow) {
			hotInputCommands.push(input);
			coldInputCommands.push(input);
		}
	}

	public function allowLookAtInput(entityId:String) {
		final entity = cast (characterEntityManager.getEntityById(entityId), EngineCharacterEntity);
		if (entity == null) {
			return false;
		} else {
			return entity.allowLookAtInput();
		}
	}

	public function allowShootInput(entityId:String) {
		final entity = cast (characterEntityManager.getEntityById(entityId), EngineCharacterEntity);
		if (entity == null) {
			return false;
		} else {
			return entity.allowShootInput();
		}
	}

	// ------------------------------------
	// Getters
	// ------------------------------------

	public function getWorldState() {
		final characterEntities = new Array<CharacterEntity>();

		for (character in characterEntityManager.getEntities()) {
			if (character.isInitiatedAndActive()) {
				characterEntities.push(character.getCharacterEntity());
			}
		}

		return characterEntities;
	}

	// ------------------------------------
	// Setters
	// ------------------------------------

	public function setPostUpdateCallback(postUpdateCallback:Void->Void) {
		this.postUpdateCallback = postUpdateCallback;
	}

	public function setProjectileHitCallback(projectileHitCallback:Array<ProjectileHit>->Void) {
		this.projectileHitCallback = projectileHitCallback;
	}

}
