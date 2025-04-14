package game.impl.scene.impl.test;

import h2d.Graphics;
import h3d.Engine;
import hxd.Key;
import hxsl.Types.Vec;
import hxsl.Types.Vec4;

import engine.base.geom.Rectangle;
import engine.base.geom.Line;
import engine.base.geom.Point;
import engine.base.geom.Circle;
import engine.base.MathUtils;

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
    final raySightLength = 1200;

    final character1:h2d.Bitmap;
    final character2:h2d.Bitmap;

    final fogOfWarGraphics:Graphics;

    final envs = new Array<Environment>();

	public function new() {
		super();

        character1 = new h2d.Bitmap(h2d.Tile.fromColor(0x77FF77, 70, 120).center(), this);
        character2 = new h2d.Bitmap(h2d.Tile.fromColor(0xFE6D6D, 70, 120).center(), this);

        character1.setPosition(900, 900);
        character2.setPosition(1300, 500);

        envs.push(new Environment(this, 1300, 400, 500, 50));
        envs.push(new Environment(this, 1300, 700, 500, 50));

        fogOfWarGraphics = new Graphics(this);
	}

	// --------------------------------------
	// Abstraction
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
        GraphicsUtils.DrawCircle(debugGraphics, new Circle(character1.x, character1.y, circleSightLength), Colors.GreenColor);
        fogOfWarGraphics.clear();
        processRect(envs[0].rectangle);
        processRect(envs[1].rectangle);
    }
    
    public function absDestroy() {
    }

    private function processRect(rect:Rectangle) {
        final characterCenter = new Point(character1.x, character1.y);

        final topLeftVertex = rect.getTopLeftPoint();
        final topRightVertex = rect.getTopRightPoint();
        final bottomLeftVertex = rect.getBottomLeftPoint();
        final bottomRightVertex = rect.getBottomRightPoint();

        final topLeftVertexToCharAngle = MathUtils.angleBetweenPoints(topLeftVertex, characterCenter) + Math.PI - MathUtils.degreeToRads(0.1);
        final topRightVertexToCharAngle = MathUtils.angleBetweenPoints(topRightVertex, characterCenter) + Math.PI + MathUtils.degreeToRads(0.1);
        final bottomLeftVertexToCharAngle = MathUtils.angleBetweenPoints(bottomLeftVertex, characterCenter) + Math.PI - MathUtils.degreeToRads(0.1);
        final bottomRightVertexToCharAngle = MathUtils.angleBetweenPoints(bottomRightVertex, characterCenter) + Math.PI + MathUtils.degreeToRads(0.1);

        final topLeftSightPoint = MathUtils.rotatePointAroundCenter(characterCenter.x + raySightLength, characterCenter.y, characterCenter.x, characterCenter.y, topLeftVertexToCharAngle);
        final topRightSightPoint = MathUtils.rotatePointAroundCenter(characterCenter.x + raySightLength, characterCenter.y, characterCenter.x, characterCenter.y, topRightVertexToCharAngle);
        final bottomLeftSightPoint = MathUtils.rotatePointAroundCenter(characterCenter.x + raySightLength, characterCenter.y, characterCenter.x, characterCenter.y, bottomLeftVertexToCharAngle);
        final bottomRightSightPoint = MathUtils.rotatePointAroundCenter(characterCenter.x + raySightLength, characterCenter.y, characterCenter.x, characterCenter.y, bottomRightVertexToCharAngle);

        final topLeftSightLine = new Line(characterCenter.x, characterCenter.y, topLeftSightPoint.x, topLeftSightPoint.y);
        final topRightSightLine = new Line(characterCenter.x, characterCenter.y, topRightSightPoint.x, topRightSightPoint.y);
        final bottomLeftSightLine = new Line(characterCenter.x, characterCenter.y, bottomLeftSightPoint.x, bottomLeftSightPoint.y);
        final bottomRightSightLine = new Line(characterCenter.x, characterCenter.y, bottomRightSightPoint.x, bottomRightSightPoint.y);

        final vertexes = new Array<Point>();

        final lines = new Array<Line>();

        var topLeftCollision = false;
        if (!rect.intersectsWithLine(topLeftSightLine)) {
            topLeftCollision = true;
            lines.push(topLeftSightLine);
            vertexes.push(topLeftVertex);
            vertexes.push(new Point(topLeftSightLine.x2, topLeftSightLine.y2));
        }
        if (!rect.intersectsWithLine(topRightSightLine)) {
            lines.push(topRightSightLine);
        }
        if (!rect.intersectsWithLine(bottomLeftSightLine)) {
            lines.push(bottomLeftSightLine);
        }
        if (!rect.intersectsWithLine(bottomRightSightLine)) {
            lines.push(bottomRightSightLine);

            if (topLeftCollision) {
                vertexes.push(new Point(bottomRightSightLine.x2, bottomRightSightLine.y2));
                vertexes.push(bottomRightVertex);
                vertexes.push(topRightVertex);
                vertexes.push(topLeftVertex);
            }
        }

        for (line in lines) {
            GraphicsUtils.DrawLine(debugGraphics, line.x1, line.y1, line.x2, line.y2, Colors.GreenColor);
        }
        if (vertexes.length > 0) {
            GraphicsUtils.DrawLines(debugGraphics, Colors.RedColor, vertexes);
            GraphicsUtils.DrawPolygon(fogOfWarGraphics, Colors.BlackColor, vertexes);
        }
    }
}

// короче схематично надо сделать вот что, по шагам, мб нам так проще будет
// 1) понять, какие именно крайние вершины прямоугольника попадают в поле зрения, в примере это левая верхняя и правая нижняя
// 2) сделать так, чтобы эти вершины определялись автоматически, вне зависимости от угла взора, положения в пространстве и тд