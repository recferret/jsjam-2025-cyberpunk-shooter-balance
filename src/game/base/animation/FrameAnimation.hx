package game.base.animation;

import h2d.Anim;

class FrameAnimation extends Anim {

    private final tiles:Array<h2d.Tile>;

    public function new(tiles:Array<h2d.Tile>, hideOnEnd:Bool = false) {
        super();

        this.tiles = tiles;

        onAnimEnd = function callback() {
            if (hideOnEnd)
                alpha = 0;
        };
        loop = true;
    }

    public function playAnimation() {
        play(tiles);
    }

    public function flipX() {
        for (frame in frames) {
            frame.flipX();
        }
    }

}