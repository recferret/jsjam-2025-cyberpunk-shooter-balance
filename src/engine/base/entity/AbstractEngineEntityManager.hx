package engine.base.entity;

import engine.base.types.EntityTypes.EntityMinDetails;

// F - Object factory
// E - Entity super class
@:generic
abstract class AbstractEngineEntityManager<F, E> {
	private var entities = new Map<String, E>();
	private final entityIdByOwnerId = new Map<String, String>();

	private var entitiesToCreateNextTick = new Array<E>();
	private var entitiesToDeleteNextTick = new Array<String>();

	private final factory:F;

	private final poolSize:Int;

	private var createEntityQueue = new Array<E>();
	private var deleteEntityQueue = new Array<E>();

	public function new(poolSize:Int, factory:F) {
		this.poolSize = poolSize;
		this.factory = factory;

		initPool();
    }

	// ------------------------------------
	// Abstraction
	// ------------------------------------

	abstract function initPool():Void;

	abstract function initiate(entity:E):Void;

	abstract function entityUpdated(entity:E):Void;

	abstract function entitiesCreated(entities:Array<E>):Void;

	abstract function entitiesDeleted(ids:Array<String>):Void;

	// ------------------------------------
	// General
	// ------------------------------------

	public function update(dt:Float) {
		for (entity in getActiveEntities()) {
			castToAbsEntity(entity).update(dt);
			entityUpdated(entity);
		}
	}

	public function dispose() {
		entities.clear();
	}

	private function castToAbsEntity(f:E) {
		return cast(f, AbstractEngineEntity);
	}

	// ------------------------------------
	// Entity management
	// ------------------------------------

	public function addEntitiesToPool(objects:Array<E>) {
		for (object in objects) {
			entities.set(cast(object, AbstractEngineEntity).getId(), object);
		}
	}

	public function assignEntityToOwnerAndActivate(entityMinDetails:EntityMinDetails) {
		for (value in entities) {
			final entity = cast(value, AbstractEngineEntity);
			if (entity.getEntityType() == entityMinDetails.entityType && !entity.poolAssigned) {
				entity.aiControlled = entityMinDetails.aiControlled;
				entity.poolAssigned = true;
				entity.active = true;
				entity.setOwnerId(entityMinDetails.ownerId);
				entity.setX(entityMinDetails.x);
				entity.setY(entityMinDetails.y);
				if (entityMinDetails.rotation != null) {
					entity.setRotation(entityMinDetails.rotation);
				}
				if (entityMinDetails.id != null) {
					entity.setId(entityMinDetails.id);
					entities.remove(entity.getId());
					entities.set(entity.getId(), value);
				}
				entitiesToCreateNextTick.push(value);
				entityIdByOwnerId.set(entity.getOwnerId(), entity.getId());
				break;
			}
		}
	}

	public function initiateEntity(entity:E) {
		final e = castToAbsEntity(entity);
		e.setInitiated();
		initiate(entity);
	}

	public function createMarkedEntities() {
		if (entitiesToCreateNextTick.length > 0) {
			entitiesCreated(entitiesToCreateNextTick);
			entitiesToCreateNextTick = [];
		}
	}

	public function deleteMarkedEntities() {
		if (entitiesToDeleteNextTick.length > 0) {
			for (id in entitiesToDeleteNextTick) {
				castToAbsEntity(entities.get(id)).dispose();
				entities.remove(id);	
			}
			entitiesDeleted(entitiesToDeleteNextTick);
			entitiesToDeleteNextTick = [];
		}
	}

	public function deactivateAndPrepareToDelete(id:String) {
		final entity = castToAbsEntity(entities.get(id));
		entity.active = false;
		entitiesToDeleteNextTick.push(id);
	}

	public function deactivateEntity(id:String) {
		cast(entities.get(id), AbstractEngineEntity).active = false;
	}

	public function getEntities() {
		final result = new Array<E>();
		for (entity in entities.iterator()) {
			result.push(entity);
		}
		return result;
	}

	public function getActiveEntities() {
		final result = new Array<E>();
		for (entity in entities.iterator()) {
			final e = castToAbsEntity(entity);
			if (e.isInitiatedAndActive()) {
				result.push(entity);
			}
		}
		return result;
	}

	public function getChangedEntities() {
		final result = new Array<E>();
		for (entity in entities.iterator()) {
			if (cast(entity, AbstractEngineEntity).isChanged()) {
				result.push(entity);
			}
		}
		return result;
	}

	public function getEntityById(id:String) {
		return entities.get(id);
	}

	public function getEntityByOwner(ownerId:String) {
		return entities.get(entityIdByOwnerId.get(ownerId));
	}

}