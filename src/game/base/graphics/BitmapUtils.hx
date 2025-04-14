package game.base.graphics;

class BitmapUtils {

    public static function createFromColoredTile(w:Int, h:Int, color:Int) {
        final tile = h2d.Tile.fromColor(color, w, h).center();
        return new h2d.Bitmap(tile);
    }

}