package game.base.graphics;

import engine.base.geom.Line;
import engine.base.geom.Point;
import engine.base.geom.Rectangle;
import engine.base.geom.Circle;

class GraphicsUtils {

    public static function DrawCircle(graphics:h2d.Graphics, circle:Circle, color:Int) {
		graphics.lineStyle(2, color);
		graphics.drawCircle(circle.x, circle.y, circle.r);
		graphics.endFill();
	}

	public static function DrawLine(graphics:h2d.Graphics, line:Line, color:Int) {
		graphics.lineStyle(1, color, 1);
		graphics.moveTo(line.x1, line.y1);
		graphics.lineTo(line.x2, line.y2);
		graphics.endFill();
	}

	public static function DrawLines(graphics:h2d.Graphics, color:Int, points:Array<Point>) {
		graphics.lineStyle(2, color);
		graphics.moveTo(points[0].x, points[0].y);

		var index = 0;
		for (point in points) {
			if (index > 0) {
				graphics.lineTo(point.x, point.y);

			}
			index++;
		}
		graphics.endFill();
	}

	public static function DrawPolygon(graphics:h2d.Graphics, color:Int, vertexes:Array<Point>) {
		if (vertexes.length < 3) return;
	
		graphics.beginFill(color, 0.4);
		graphics.moveTo(vertexes[0].x, vertexes[0].y);
		for (i in 1...vertexes.length) {
			graphics.lineTo(vertexes[i].x, vertexes[i].y);
		}

		graphics.endFill();
	}

	public static function DrawRect(graphics:h2d.Graphics, rect:Rectangle, color:Int) {
		graphics.lineStyle(1, color);
		// Top line
		graphics.lineTo(rect.getTopLeftPoint().x, rect.getTopLeftPoint().y);
		graphics.lineTo(rect.getTopRightPoint().x, rect.getTopRightPoint().y);
		// Right line
		graphics.lineTo(rect.getBottomRightPoint().x, rect.getBottomRightPoint().y);
		// Bottom line
		graphics.lineTo(rect.getBottomLeftPoint().x, rect.getBottomLeftPoint().y);
		// Left line
		graphics.lineTo(rect.getTopLeftPoint().x, rect.getTopLeftPoint().y);
	}

	public static function DrawRectFilled(graphics:h2d.Graphics, rect:Rectangle, color:Int) {
		graphics.beginFill(color);
		graphics.drawRect(rect.x, rect.y, rect.w, rect.h);
		graphics.endFill();
	}

}