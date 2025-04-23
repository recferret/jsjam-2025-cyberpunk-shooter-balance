package engine.base;

import engine.base.geom.Line;
import engine.base.geom.Point;

class MathUtils {

	public static function degreeToRads(degrees:Float) {
		return (Math.PI / 180) * degrees;
	}

	public static function radsToDegree(rads:Float) {
		return rads * (180 / Math.PI);
	}

	public static function normalizeAngle(rads:Float) {
		rads = rads % (2 * Math.PI);
		if (rads >= 0) {
			return rads;
		} else {
			return rads + 2 * Math.PI;
		}
	}

	public static function distanceTravelled(x:Float, y:Float) {
		return Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
	}

    public static function angleBetweenPoints(point1:Point, point2:Point) {
		return Math.atan2(point2.y - point1.y, point2.x - point1.x);
	}

	public static function rotatePointAroundCenter(x:Float, y:Float, cx:Float, cy:Float, r:Float) {
		final cos = Math.cos(r);
		final sin = Math.sin(r);
		return new Point((cos * (x - cx)) - (sin * (y - cy)) + cx, (cos * (y - cy)) + (sin * (x - cx)) + cy);
	}

	public static function lineToLineIntersection(lineA:Line, lineB:Line) {
		final numA = (lineB.x2 - lineB.x1) * (lineA.y1 - lineB.y1) - (lineB.y2 - lineB.y1) * (lineA.x1 - lineB.x1);
		final numB = (lineA.x2 - lineA.x1) * (lineA.y1 - lineB.y1) - (lineA.y2 - lineA.y1) * (lineA.x1 - lineB.x1);
		final deNom = (lineB.y2 - lineB.y1) * (lineA.x2 - lineA.x1) - (lineB.x2 - lineB.x1) * (lineA.y2 - lineA.y1);
		if (deNom == 0) {
			return false;
		}
		final uA = numA / deNom;
		final uB = numB / deNom;
		return uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1;
	}

	public static function differ(a:Float, b:Float, error:Float) {
		return Math.abs(a - b) > (error == 0 ? 1 : error);
	}

	public static function differInt(a:Int, b:Int, error:Int) {
		return Math.abs(a - b) > (error == 0 ? 1 : error);
	}

	public static function randomIntInRange(min:Int, max:Int, sign=false) {
		if (sign)
			return (min + Std.random(max - min + 1)) * (Std.random(2) * 2 - 1);
		else
			return min + Std.random(max - min + 1);
	}

	public static function randomFloatInRange(min:Float, max:Float, sign=false) {
		if (sign)
			return (min + Math.random() * (max - min)) * (Std.random(2) * 2 - 1);
		else
			return min + Math.random() * (max - min);
	}

	public static function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
        final dx = x2 - x1;
        final dy = y2 - y1;
        return Math.sqrt(dx * dx + dy * dy);
    }

}