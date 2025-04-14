package engine.impl.types;

import engine.base.types.EntityTypes.BaseEntity;
import engine.base.types.EntityTypes.BaseEntityStruct;

typedef ProjectileEntityStruct = {
    base:BaseEntityStruct,
}

class ProjectileEntity extends BaseEntity {
	public function new(struct:ProjectileEntityStruct) {
		super(struct.base);
	}
}