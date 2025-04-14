package game.impl.scene.impl.test;

import h2d.col.Point;
import h3d.Engine;
import hxd.Window;

import engine.base.MathUtils;
import engine.base.geom.Rectangle;
import engine.base.geom.Line;

import game.base.scene.AbstractScene;
import game.base.graphics.GraphicsUtils;

class GeomTestScene extends AbstractScene {
	// Two rect collides with each other
	private final rect1 = new Rectangle(200, 200, 300, 300, 0);
	private final rect2 = new Rectangle(200, 550, 300, 300, 0);
	// Rect to collide with mouse
	private final mouseRect = new Rectangle(1100, 400, 300, 500, 0);

	public function new() {
		super();
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
		// ------------------------------------------
		// Two rect collide test
		// ------------------------------------------
		rect2.r += MathUtils.degreeToRads(0.1);
		var collideRectColor = Colors.GreenColor;
		if (rect1.intersectsWithRect(rect2)) {
			collideRectColor = Colors.RedColor;
		}
		GraphicsUtils.DrawRect(debugGraphics, rect1, collideRectColor);
		GraphicsUtils.DrawRect(debugGraphics, rect2, collideRectColor);
		// ------------------------------------------
		// Mouse cursor and rect collide test
		// ------------------------------------------
		mouseRect.r += MathUtils.degreeToRads(0.1);
		final mousePos = new Point(Window.getInstance().mouseX, Window.getInstance().mouseY);
		final mouseToCameraPos = new Point(mousePos.x, mousePos.y);
		camera.sceneToCamera(mouseToCameraPos);
		final cursorToMouseRectLine = new Line(mouseToCameraPos.x, mouseToCameraPos.y, mouseRect.x, mouseRect.y);
		var mouseRectColor = Colors.YellowColor;
		if (mouseRect.getLines().lineB.intersectsWithLine(cursorToMouseRectLine)
			|| mouseRect.getLines().lineD.intersectsWithLine(cursorToMouseRectLine)) {
			mouseRectColor = Colors.RedColor;
		}
		GraphicsUtils.DrawRect(debugGraphics, mouseRect, mouseRectColor);
		debugGraphics.lineStyle(3, Colors.YellowColor);
		debugGraphics.moveTo(cursorToMouseRectLine.x1, cursorToMouseRectLine.y1);
		debugGraphics.lineTo(cursorToMouseRectLine.x2, cursorToMouseRectLine.y2);
	}

    public function absRender(e:Engine) {
    }
    
    public function absDestroy() {
    }

}
