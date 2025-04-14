package engine.impl;

import engine.base.geom.Rectangle;

class Border {

    public var rect:Rectangle;
    public var id:Int;

    private function new(rect:Rectangle, id:Int) {
        this.rect = rect;
        this.id = id;
    }

}

class Borders {

    public final rectangles = new Map<Int, Rectangle>();

    public static final instance:Borders = new Borders();

    private function new() {
    }

    public function rectIntersectsWithBorder(rect:Rectangle) {
        for (value in rectangles) {
            if (rect.intersectsWithRect(value)) {
                return true;
            }
        }
        return false;
    }

}

