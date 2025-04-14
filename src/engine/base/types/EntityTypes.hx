package engine.base.types;

enum abstract EntityType(String) {
	var Bullet = 'Bullet';
	var Cyberpunk = 'Cyberpunk';
}

typedef EntityMinDetails = {
    ?id:String,
    ownerId:String,
    x:Float,
    y:Float,
	entityType:EntityType,
	?rotation:Float,
	?aiControlled:Bool,
} 

typedef ShapeStruct = {
	width:Int,
	height:Int,
	rectOffsetX:Int,
	rectOffsetY:Int,
	radius:Float,
}

typedef BaseEntityStruct = {
	x:Float,
	y:Float,
	entityType:EntityType,
	entityShape:ShapeStruct,
	id:String,
	ownerId:String,
	rotation:Float,
	lookAtAngle:Float,
	aiControlled:Bool,
}

class BaseEntity {
	public var x:Float;
	public var y:Float;
	public var entityType:EntityType;
	public var entityShape:ShapeStruct;
	public var id:String;
	public var ownerId:String;
	public var rotation:Float;
	public var lookAtAngle:Float;
	public var aiControlled:Bool;

	public function new(struct:BaseEntityStruct) {
		this.x = struct.x;
		this.y = struct.y;
		this.entityType = struct.entityType;
		this.entityShape = struct.entityShape;
		this.id = struct.id;
		this.ownerId = struct.ownerId;
		this.rotation = struct.rotation;
		this.lookAtAngle = struct.lookAtAngle;
		this.aiControlled = struct.aiControlled;
	}

	public function getBaseStruct() {
		final struct:BaseEntityStruct = {
			x: this.x,
			y: this.y,
			entityType: this.entityType,
			entityShape: this.entityShape,
			id: this.id,
			ownerId: this.ownerId,
			rotation: this.rotation,
			lookAtAngle: this.lookAtAngle,
			aiControlled: this.aiControlled,
		};
		return struct;
	}
}