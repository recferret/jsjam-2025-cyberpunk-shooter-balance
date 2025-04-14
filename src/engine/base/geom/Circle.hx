package engine.base.geom;

class Circle {
	public var x:Float;
	public var y:Float;
	public var r:Float;

	public function new(x:Float, y:Float, r:Float) {
		this.x = x;
		this.y = y;
		this.r = r;
	}

	public function updatePosition(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}

	public function getCenter() {
		return new Point(x, y);
	}

	public function containsRect(rect:Rectangle) {
		final halfWidth = rect.w / 2;
		final halfHeight = rect.h / 2;
	
		final cx = Math.abs(x - rect.x - halfWidth);
		final cy = Math.abs(y - rect.y - halfHeight);
		final xDist = halfWidth + r;
		final yDist = halfHeight + r;


		if (cx > xDist || cy > yDist) {
			return false;
		}
		else if (cx <= halfWidth || cy <= halfHeight) {
			return true;
		} else {
			final xCornerDist = cx - halfWidth;
			final yCornerDist = cy - halfHeight;
			final xCornerDistSq = xCornerDist * xCornerDist;
			final yCornerDistSq = yCornerDist * yCornerDist;
			final maxCornerDistSq = r * r;
		
			return (xCornerDistSq + yCornerDistSq <= maxCornerDistSq);
		}
	}

}
