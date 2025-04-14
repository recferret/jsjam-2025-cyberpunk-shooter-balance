package engine.base.entity;

import engine.base.geom.Line;

import uuid.Uuid;

import engine.base.geom.Circle;
import engine.base.geom.Rectangle;
import engine.base.types.EntityTypes.BaseEntity;

abstract class AbstractEngineEntity {

	public var aiControlled = false;
	public var poolAssigned = false;
	public var active = false;
	public var lastDt = 0.0;
	public var side:String;

    private final baseEntity:BaseEntity;

	private var speed:Float;

    private var previousTickHash:String;
	private var currentTickHash:String;

	private var initiated = false;

    public function new(baseEntity:BaseEntity) {
        this.baseEntity = baseEntity;

		this.setId(Uuid.short());
    }

    // ------------------------------------------------
    // Abstraction
    // ------------------------------------------------

    public abstract function absUpdate(dt:Float):Void;

    // ------------------------------------------------
    // General
    // ------------------------------------------------

	public function update(dt:Float) {
		if (active && initiated) {
			absUpdate(dt);
			lastDt = dt;
		}
	}

	public function moveBy(x:Float, y:Float) {
		baseEntity.x += Std.int(x);
		baseEntity.y += Std.int(y);
	}

	public function getPastPosition(steps:Float) {
		final dx = (speed * Math.cos(baseEntity.rotation) * lastDt) * steps;
		final dy = (speed * Math.sin(baseEntity.rotation) * lastDt) * steps;

		return {
			x: baseEntity.x - dx,
			y: baseEntity.y - dy,
		}
	}

	public function getFuturePosition(steps:Float, angle:Float) {
		final dx = (speed * steps) * Math.cos(angle) * lastDt;
		final dy = (speed * steps) * Math.sin(angle) * lastDt;

		return {
			x: baseEntity.x + dx,
			y: baseEntity.y + dy,
		}
	}

	public function getFutureRectangle(steps:Float, angle:Float) {
		final pos = getFuturePosition(steps, angle);
		final shapeWidth = baseEntity.entityShape.width;
		final shapeHeight = baseEntity.entityShape.height;
		final x = pos.x;
		final y = pos.y;
		return new Rectangle(x, y, shapeWidth, shapeHeight, 0);
	}

	public function isChanged() {
		return previousTickHash != currentTickHash;
	}

	public function getLookingAtLine(lineLength:Int) {
		final rect = getBodyRectangle();
		final x1 = rect.getCenter().x;
		final y1 = rect.getCenter().y;

		final p = MathUtils.rotatePointAroundCenter(x1 + lineLength, y1, x1, y1, baseEntity.lookAtAngle);
		final x2 = p.x;
		final y2 = p.y;

		return new Line(x1, y1, x2, y2);
	}

	public function dispose() {
	}

    // ------------------------------------------------
    // Getters
    // ------------------------------------------------

	public function getBodyRectangle(rotated:Bool = false) {
		final shapeWidth = baseEntity.entityShape.width;
		final shapeHeight = baseEntity.entityShape.height;
		final x = baseEntity.x;
		final y = baseEntity.y;
		return new Rectangle(x, y, shapeWidth, shapeHeight, rotated ? baseEntity.rotation : 0);
	}

	public function getBodyCircle() {
		final x = baseEntity.x;
		final y = baseEntity.y;
		return new Circle(x, y, baseEntity.entityShape.radius);
	}

	public function isInitiated() {
		return initiated;
	}

	public function isInitiatedAndActive() {
		return initiated && active;
	}

    public function getX() {
		return baseEntity.x;
	}

	public function getY() {
		return baseEntity.y;
	}

	public function getId() {
		return baseEntity.id;
	}

	public function getEntityType() {
		return baseEntity.entityType;
	}

	public function getOwnerId() {
		return baseEntity.ownerId;
	}

	public function getRotation() {
		return baseEntity.rotation;
	}

	public function getLookAtAngle() {
		return baseEntity.lookAtAngle;
	}

    // ------------------------------------------------
    // Setters
    // ------------------------------------------------

	public function setInitiated() {
		initiated = true;
	}

	public function setId(id:String) {
		baseEntity.id = id;
	}

	public function setOwnerId(ownerId:String) {
		baseEntity.ownerId = ownerId;
	}

    public function setX(x:Float) {
		baseEntity.x = x;
	}

	public function setY(y:Float) {
		baseEntity.y = y;
	}

	public function setRotation(r:Float) {
		baseEntity.rotation = r;
	}

	public function setSpeed(speed:Float) {
		this.speed = speed;
	}

}