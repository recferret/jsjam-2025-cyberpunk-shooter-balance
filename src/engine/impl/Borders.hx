package engine.impl;

import engine.base.geom.Line;
import engine.base.geom.Rectangle;

class Borders {

    public final lines = [
        // new Line(62, 64, 158, 63),
        // new Line(158, 63, 160, 127),
        // new Line(160, 127, 286, 127),
        // new Line(286, 127, 286, 65),
        // new Line(286, 65, 510, 65),
        // new Line(510, 65, 513, 94),
        // new Line(513, 94, 574, 93),
        // new Line(574, 93, 572, 58),
        // new Line(572, 58, 964, 58),
        // new Line(964, 58, 967, 514),
        // new Line(967, 514, 932, 517),
        // new Line(932, 517, 935, 569),
        // new Line(935, 569, 962, 571),
        // new Line(962, 571, 967, 965),
        // new Line(967, 965, 923, 967),
        // new Line(923, 967, 921, 933),
        // new Line(921, 933, 837, 933),
        // new Line(837, 933, 840, 964),
        // new Line(840, 964, 506, 967),
        // new Line(506, 967, 502, 903),
        // new Line(502, 903, 425, 908),
        // new Line(425, 908, 423, 959),
        // new Line(423, 959, 281, 962),
        // new Line(281, 962, 281, 932),
        // new Line(281, 932, 166, 936),
        // new Line(166, 936, 165, 962),
        // new Line(165, 962, 60, 964),
        // new Line(60, 964, 59, 730),
        // new Line(59, 730, 90, 730),
        // new Line(90, 730, 88, 645),
        // new Line(88, 645, 58, 645),
        // new Line(58, 645, 62, 190),
        // new Line(62, 190, 93, 190),
        // new Line(93, 190, 94, 130),
        // new Line(94, 130, 63, 127),
        // new Line(63, 127, 63, 63)
    ];

    public static final instance:Borders = new Borders();

    private function new() {
    }

    public function rectIntersectsWithBorder(rect:Rectangle) {
        for (line in lines) {
            if (rect.intersectsWithLine(line)) {
                return true;
            }
        }
        return false;
    }

}

