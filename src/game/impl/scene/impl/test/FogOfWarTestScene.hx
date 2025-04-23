package game.impl.scene.impl.test;

import hxsl.Types.Vec;
import hxsl.Types.Vec4;
import h2d.Graphics;
import hxd.Key;
import h3d.Engine;

import game.base.graphics.GraphicsUtils;
import engine.base.geom.Rectangle;
import engine.base.geom.Line;
import engine.base.geom.Point;
import engine.base.geom.Circle;
import engine.base.MathUtils;

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
    final circleSightLength = 500;
    final raySightLength = 500.;

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

    public function absOnEvent(event:hxd.Event) {
    }

    public function absOnResize(w:Int, h:Int) {
    }

    public function absStart() {
    }

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
        for (t in debugTexts) t.visible = false;

        castRaysAroundCharacter();
        
        GraphicsUtils.DrawCircle(debugGraphics, new Circle(character1.x, character1.y, circleSightLength), Colors.GreenColor);

    }

    private function castRaysAroundCharacter() {
        final characterCenter = new Point(character1.x, character1.y);
        fogOfWarGraphics.clear();
        
        var allSegments = new Array<Line>();
        var allObstacles = new Array<Array<Point>>();
        
        // Добавляем отрезки всех препятствий в массив
        for (env in envs) {
            var rect = env.rectangle;
            // Получаем все вершины прямоугольника
            var topLeft = rect.getTopLeftPoint();
            var topRight = rect.getTopRightPoint();
            var bottomLeft = rect.getBottomLeftPoint();
            var bottomRight = rect.getBottomRightPoint();
            
            // Проверяем, находится ли хотя бы одна вершина в зоне видимости
            var isInSight = false;
            if (MathUtils.distance(characterCenter.x, characterCenter.y, topLeft.x, topLeft.y) <= circleSightLength ||
                MathUtils.distance(characterCenter.x, characterCenter.y, topRight.x, topRight.y) <= circleSightLength ||
                MathUtils.distance(characterCenter.x, characterCenter.y, bottomLeft.x, bottomLeft.y) <= circleSightLength ||
                MathUtils.distance(characterCenter.x, characterCenter.y, bottomRight.x, bottomRight.y) <= circleSightLength) {
                isInSight = true;
            }
            
            // Если препятствие не в зоне видимости, пропускаем его
            if (!isInSight) continue;
            
            // Добавляем отрезки этого препятствия
            allSegments.push(new Line(topLeft.x, topLeft.y, topRight.x, topRight.y));
            allSegments.push(new Line(topRight.x, topRight.y, bottomRight.x, bottomRight.y));
            allSegments.push(new Line(bottomLeft.x, bottomLeft.y, bottomRight.x, bottomRight.y));
            allSegments.push(new Line(topLeft.x, topLeft.y, bottomLeft.x, bottomLeft.y));
            
            // Сохраняем вершины этого препятствия
            allObstacles.push([topLeft, topRight, bottomRight, bottomLeft]);
        }
        
        // Если нет препятствий в зоне видимости, просто выходим
        if (allObstacles.length == 0) return;
        
        // Для каждого препятствия строим отдельный полигон
        for (obstacle in allObstacles) {
            var rayEndPoints = new Array<Point>();
            final epsilon = 0.00001;
            
            // Для каждой вершины препятствия бросаем лучи
            // З.Ы. Если не бросать дополнительные лучи 
            // То полигоны будут трястись еще жестче, чем сейчас
            for (point in obstacle) {
                // Основной луч прямо к точке
                castRayToPoint(characterCenter, point, allSegments, rayEndPoints);
                
                // Луч с небольшим отклонением влево
                var angle = Math.atan2(point.y - characterCenter.y, point.x - characterCenter.x);
                var leftAngle = angle - epsilon;
                var leftPoint = new Point(
                    characterCenter.x + Math.cos(leftAngle) * raySightLength,
                    characterCenter.y + Math.sin(leftAngle) * raySightLength
                );
                castRayToPoint(characterCenter, leftPoint, allSegments, rayEndPoints);
                
                // Луч с небольшим отклонением вправо
                var rightAngle = angle + epsilon;
                var rightPoint = new Point(
                    characterCenter.x + Math.cos(rightAngle) * raySightLength,
                    characterCenter.y + Math.sin(rightAngle) * raySightLength
                );
                castRayToPoint(characterCenter, rightPoint, allSegments, rayEndPoints);
            }
            
            // Сортируем точки по углу относительно центра персонажа
            rayEndPoints.sort(function(a, b) {
                var angleA = Math.atan2(a.y - characterCenter.y, a.x - characterCenter.x);
                var angleB = Math.atan2(b.y - characterCenter.y, b.x - characterCenter.x);
                return angleA < angleB ? -1 : 1;
            });
            
            // Строим полигон для каждого препятствия
            if (rayEndPoints.length > 0) {
                var vertices = new Array<Point>();
                vertices.push(characterCenter);
                vertices = vertices.concat(rayEndPoints);
                vertices.push(rayEndPoints[0]); // Замыкаем полигон
                
                GraphicsUtils.DrawPolygon(fogOfWarGraphics, Colors.BlackColor, vertices);
            }
        }
        
        for (env in envs) {
            var rect = env.rectangle;
            var topLeft = rect.getTopLeftPoint();
            var topRight = rect.getTopRightPoint();
            var bottomLeft = rect.getBottomLeftPoint();
            var bottomRight = rect.getBottomRightPoint();
        }
    }
    
    // Добавляет точку в массив, если её там ещё нет
    private function addUniquePoint(points:Array<Point>, newPoint:Point) {
        for (p in points) {
            if (p.x == newPoint.x && p.y == newPoint.y) {
                return; 
            }
        }
        points.push(newPoint);
    }
    
    // Бросает луч от characterCenter к targetPoint и находит ближайшее пересечение
    // Но тут уже пошла зона, где я пытался натянуть сову (пример той девочки)
    // на глобус (мой код, хотя я делал это уже выше)
    //Поэтому все алгоритмы тут написаны по ее формуле (ну типо)
    private function castRayToPoint(characterCenter:Point, targetPoint:Point, segments:Array<Line>, result:Array<Point>) {
        var rayDirX = targetPoint.x - characterCenter.x;
        var rayDirY = targetPoint.y - characterCenter.y;
        var rayLength = Math.sqrt(rayDirX * rayDirX + rayDirY * rayDirY);
        rayDirX /= rayLength;
        rayDirY /= rayLength;
        
        var closestIntersection:Point = null;
        var closestDistance = raySightLength;
        
        for (segment in segments) {
            // Параметры луча
            var r_px = characterCenter.x;
            var r_py = characterCenter.y;
            var r_dx = rayDirX;
            var r_dy = rayDirY;
            
            // Параметры отрезка
            var s_px = segment.x1;
            var s_py = segment.y1;
            var s_dx = segment.x2 - segment.x1;
            var s_dy = segment.y2 - segment.y1;
            
            // Проверка на параллельность
            var denominator = s_dx * r_dy - s_dy * r_dx;
            if (Math.abs(denominator) < 0.0001) continue;
            
            // Вычисляем T2 (параметр отрезка)
            var T2 = (r_dx * (s_py - r_py) + r_dy * (r_px - s_px)) / denominator;
            // Вычисляем T1 (параметр луча)
            var T1 = (s_px + s_dx * T2 - r_px) / r_dx;
            
            // Проверяем условия пересечения
            if (T1 > 0 && T2 >= 0 && T2 <= 1) {
                var intersection = new Point(
                    r_px + r_dx * T1,
                    r_py + r_dy * T1
                );
                var dist = Math.sqrt(
                    (intersection.x - r_px) * (intersection.x - r_px) + 
                    (intersection.y - r_py) * (intersection.y - r_py)
                );
                
                if (dist < closestDistance) {
                    closestDistance = dist;
                    closestIntersection = intersection;
                }
            }
        }
        
        if (closestIntersection != null) {
            result.push(closestIntersection);
        } else {
            // Если пересечений нет, добавляем точку на максимальном расстоянии 
            // Возможно тут тоже косяк, потому что масимальное расстояние - это всегда raySightLength 
            // Но на этом моменте тут уже было достаточно военных преступлений
            result.push(new Point(
                characterCenter.x + rayDirX * raySightLength,
                characterCenter.y + rayDirY * raySightLength
            ));
        }
    }
    

    public function absDestroy() {
    }

    // Function to print debug text on the screen
    private function printDebugText(x:Float, y:Float, msg:String) {
        if (debugTextIndex >= debugTexts.length) return;
        var t = debugTexts[debugTextIndex++];
        t.text = msg;
        t.setPosition(x, y);
        t.visible = true;
    }
}