package game.impl.scene.impl.test;

import h2d.Graphics;
import h3d.Engine;
import hxd.Key;

import engine.base.geom.Rectangle;
import engine.base.geom.Line;
import engine.base.geom.Point;
import engine.base.geom.Circle;

import game.base.graphics.GraphicsUtils;
import game.base.scene.AbstractScene;

class Environment {
	final bmp:h2d.Bitmap;

	public final rectangle:Rectangle;

	public function new(parent:h2d.Object, x:Float, y:Float, w:Int, h:Int) {
		bmp = new h2d.Bitmap(h2d.Tile.fromColor(0x6F6F77, w, h).center(), parent);
		bmp.alpha = 0.5;
		bmp.setPosition(x, y);
		rectangle = new Rectangle(x, y, w, h, 0);
	}
}

class FogOfWarTestScene extends AbstractScene {
	final moveSpeed = 100;
	final circleSightLength = 800;
	final raySightLength = 800.;

	final character1:h2d.Bitmap;
	final character2:h2d.Bitmap;

	final fogOfWarGraphics:Graphics;
	final debugTexts = new Array<h2d.Text>();
	final textFont = hxd.res.DefaultFont.get();
	var debugTextIndex = 0;

	final envs = new Array<Environment>();

	public function new() {
		super();

		character1 = new h2d.Bitmap(h2d.Tile.fromColor(0x77FF77, 70, 120).center(), this);
		character2 = new h2d.Bitmap(h2d.Tile.fromColor(0xFE6D6D, 70, 120).center(), this);

		character1.setPosition(900, 900);
		character2.setPosition(1300, 500);

		envs.push(new Environment(this, 1300, 700, 500, 50));

		envs.push(new Environment(this, 600, 400, 300, 80));

		envs.push(new Environment(this, 200, 200, 200, 80));

		fogOfWarGraphics = new Graphics(this);

		// Initialize debug texts
		for (i in 0...20) {
			var t = new h2d.Text(textFont, this);
			t.textColor = 0xFFFFFF;
			t.scale(1.0);
			t.visible = false;
			debugTexts.push(t);
		}
	}

	// --------------------------------------
	// Abstractions
	// --------------------------------------

	public function absOnEvent(event:hxd.Event) {}

	public function absOnResize(w:Int, h:Int) {}

	public function absStart() {}

	public function absUpdate(dt:Float, fps:Float) {
		if (Key.isDown(Key.W)) {
			character1.y -= moveSpeed * dt;
		}
		if (Key.isDown(Key.A)) {
			character1.x -= moveSpeed * dt;
		}
		if (Key.isDown(Key.S)) {
			character1.y += moveSpeed * dt;
		}
		if (Key.isDown(Key.D)) {
			character1.x += moveSpeed * dt;
		}
	}

	public function absRender(e:Engine) {
		debugTextIndex = 0;
		// Hide all debug texts
		for (t in debugTexts)
			t.visible = false;

		castRaysAroundCharacter();

		GraphicsUtils.DrawCircle(debugGraphics, new Circle(character1.x, character1.y, circleSightLength), Colors.GreenColor);
		// processRect(envs[0].rectangle);
	}

	private function castRaysAroundCharacter() {
		final characterCenter = new Point(character1.x, character1.y);
		fogOfWarGraphics.clear();

		// Собираем все отрезки препятствий для проверки пересечений
		final allSegments = new Array<Line>();
		final allSegmentPoints = new Array<Point>();
		for (env in envs) {
			final rect = env.rectangle;
			final topLeft = rect.getTopLeftPoint();
			final topRight = rect.getTopRightPoint();
			final bottomLeft = rect.getBottomLeftPoint();
			final bottomRight = rect.getBottomRightPoint();

			allSegments.push(new Line(topLeft.x, topLeft.y, topRight.x, topRight.y));
			allSegments.push(new Line(topRight.x, topRight.y, bottomRight.x, bottomRight.y));
			allSegments.push(new Line(bottomRight.x, bottomRight.y, bottomLeft.x, bottomLeft.y));
			allSegments.push(new Line(bottomLeft.x, bottomLeft.y, topLeft.x, topLeft.y));

			allSegmentPoints.push(topLeft);
			allSegmentPoints.push(topRight);
			allSegmentPoints.push(bottomLeft);
			allSegmentPoints.push(bottomRight);
		}

		final rayCount = 360;
		final rayEndPoints = new Array<Point>();

		// Стандартная круговая сетка
		for (i in 0...rayCount) {
			final angle = (Math.PI * 2) * i / rayCount;
			final rayDir = new Point(Math.cos(angle), Math.sin(angle));
			final target = new Point(characterCenter.x + rayDir.x * raySightLength, characterCenter.y + rayDir.y * raySightLength);
			castRayToPoint(characterCenter, target, allSegments, rayEndPoints);
		}

		// ➕ Добавляем "смещённые" лучи к вершинам препятствий
		final delta = 0.0001;
		for (point in allSegmentPoints) {
			final baseAngle = Math.atan2(point.y - characterCenter.y, point.x - characterCenter.x);
			final angles = [baseAngle - delta, baseAngle, baseAngle + delta];

			for (a in angles) {
				final targetX = characterCenter.x + Math.cos(a) * raySightLength;
				final targetY = characterCenter.y + Math.sin(a) * raySightLength;
				castRayToPoint(characterCenter, new Point(targetX, targetY), allSegments, rayEndPoints);
			}
		}

		// Сортировка точек по углу
		rayEndPoints.sort(function(p1, p2) {
			final angle1 = Math.atan2(p1.y - characterCenter.y, p1.x - characterCenter.x);
			final angle2 = Math.atan2(p2.y - characterCenter.y, p2.x - characterCenter.x);
			return (angle1 > angle2) ? 1 : (angle1 < angle2) ? -1 : 0;
		});

		// Рисуем полигон
		if (rayEndPoints.length > 0) {
			final vertices = [characterCenter].concat(rayEndPoints);
			vertices.push(rayEndPoints[0]); // замыкаем
			GraphicsUtils.DrawPolygon(fogOfWarGraphics, Colors.BlackColor, vertices);
		}
	}

	// Добавляет точку в массив, если её там ещё нет
	private function addUniquePoint(points:Array<Point>, newPoint:Point) {
		for (p in points) {
			if (p.x == newPoint.x && p.y == newPoint.y) {
				return; // Точка уже есть в массиве
			}
		}
		points.push(newPoint);
	}

	// Бросает луч от characterCenter к targetPoint и находит ближайшее пересечение
	private function castRayToPoint(characterCenter:Point, targetPoint:Point, segments:Array<Line>, result:Array<Point>) {
		var rayDirX = targetPoint.x - characterCenter.x;
		var rayDirY = targetPoint.y - characterCenter.y;
		final rayLength = Math.sqrt(rayDirX * rayDirX + rayDirY * rayDirY);
		rayDirX /= rayLength;
		rayDirY /= rayLength;

		var closestIntersection:Point = null;
		var closestDistance = raySightLength;

		for (segment in segments) {
			// Параметры луча
			final r_px = characterCenter.x;
			final r_py = characterCenter.y;
			final r_dx = rayDirX;
			final r_dy = rayDirY;

			// Параметры отрезка
			final s_px = segment.x1;
			final s_py = segment.y1;
			final s_dx = segment.x2 - segment.x1;
			final s_dy = segment.y2 - segment.y1;

			// Проверка на параллельность
			final denominator = s_dx * r_dy - s_dy * r_dx;

			// Если r_dx == 0 (вертикальный луч), особая обработка
			if (Math.abs(r_dx) < 0.0001) {
				if (Math.abs(s_dx) < 0.0001) {
					// Если отрезок тоже вертикален, проверяем, пересекаются ли они по Y
					if (Math.abs(s_px - r_px) < 0.0001) {
						final t2 = (r_py - s_py) / s_dy;
						if (t2 >= 0 && t2 <= 1) {
							final intersection = new Point(r_px, s_py + s_dy * t2);
							final dist = Math.sqrt((intersection.x - r_px) * (intersection.x - r_px) + (intersection.y - r_py) * (intersection.y - r_py));
							if (dist < closestDistance) {
								closestDistance = dist;
								closestIntersection = intersection;
							}
						}
					}
				} else {
					// Если отрезок не вертикален, ищем пересечение с вертикальной осью луча
					final t2 = (r_px - s_px) / s_dx;
					if (t2 >= 0 && t2 <= 1) {
						final intersection = new Point(r_px, s_py + s_dy * t2);
						final dist = Math.sqrt((intersection.x - r_px) * (intersection.x - r_px) + (intersection.y - r_py) * (intersection.y - r_py));
						if (dist < closestDistance) {
							closestDistance = dist;
							closestIntersection = intersection;
						}
					}
				}
			} else if (Math.abs(denominator) > 0.0001) {
				// Стандартная проверка для обычных лучей
				final T2 = (r_dx * (s_py - r_py) + r_dy * (r_px - s_px)) / denominator;
				final T1 = (s_px + s_dx * T2 - r_px) / r_dx;

				if (T1 > 0 && T2 >= 0 && T2 <= 1) {
					final intersection = new Point(r_px + r_dx * T1, r_py + r_dy * T1);
					final dist = Math.sqrt((intersection.x - r_px) * (intersection.x - r_px) + (intersection.y - r_py) * (intersection.y - r_py));

					if (dist < closestDistance) {
						closestDistance = dist;
						closestIntersection = intersection;
					}
				}
			}
		}

		if (closestIntersection != null) {
			result.push(closestIntersection);
		} else {
			// Если пересечений нет, добавляем точку на максимальном расстоянии
			result.push(new Point(characterCenter.x + rayDirX * raySightLength, characterCenter.y + rayDirY * raySightLength));
		}
	}

	public function absDestroy() {}
}
