package game.impl.scene.impl.test;

import h2d.Drawable;
import h2d.filter.DropShadow;
import h2d.col.Point;
import h3d.Engine;

import engine.base.MathUtils;

import game.base.graphics.GraphicsUtils;
import game.base.scene.AbstractScene;

class FogOfWarShader extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d;

        @param var texture:Sampler2D;
        @param var fogSize:Vec2;
        @param var playerSize:Vec2;
        @param var playerPos:Vec2;
        @param var radius:Float;

        @param var trianglePointA:Vec2;
        @param var trianglePointB:Vec2;
        @param var trianglePointC:Vec2;

        function distanceBetweenPoints(p1:Vec2, p2:Vec2):Float {
            var dx = p1.x - p2.x;
            var dy = p1.y - p2.y;
            return sqrt(dx * dx + dy * dy);
        }

        function ifPixelInAPlayerCircle(p:Vec2):Bool {
            var dx = (playerPos.x - p.x);
            var dy = (playerPos.y - p.y);
            var d = dx * dx + dy * dy - radius * radius;
            return d < 0;
        }

        function ifPixelInAPlayerTriangle(p:Vec2):Bool {
            var a = trianglePointA;
            var b = trianglePointB;
            var c = trianglePointC;
            var area = 1 / (((a.y * b.x - a.x * b.y) + (b.y * c.x - b.x * c.y) + (c.y * a.x - c.x * a.y)) * -1);
            var s = area * (a.y * c.x - a.x * c.y + (c.y - a.y) * p.x + (a.x - c.x) * p.y);
            var t = area * (a.x * b.y - a.y * b.x + (a.y - b.y) * p.x + (b.x - a.x) * p.y);
            return s >= 0 && t >= 0 && s + t < 1;
        }

        function fragment() {
            var p = vec2(calculatedUV.x * fogSize.x, calculatedUV.y * fogSize.y);

            var alpha = 1.0;

            if (ifPixelInAPlayerCircle(p) || ifPixelInAPlayerTriangle(p)) {
                // var distance = distanceBetweenPoints(p, playerPos);
                // if (distance < 200) alpha = 0.0; else alpha = 0.1;
                alpha = 0.0;
            }

            pixelColor = vec4(0, 0, 0, alpha);
        }
    }
}

// class WaveShader extends h3d.shader.ScreenShader {
class WaveShader extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d;

        @param var screenSize:Vec2;
        @param var strength:Float = 0.08;
        @param var radius:Float = 0.25;
        @param var center:Vec2;
        @param var aberration:Float = 0.425;
        @param var width:Float = 0.04;
        @param var feather:Float = 0.135;
        @param var texture:Sampler2D;


        @param var t:Float = 0.0;
        @param var aspect:Vec2;

        var maxRadius:Float = 0.5;

        // @param var global_position:Vec2;
        // @param var screen_size:Vec2;
        // @param var force:Float;
        // @param var size:Float;
        // @param var thickness:Float;
        // @param var texture:Sampler2D;

        function sdBox(p:Vec2, b:Vec2):Float {
            var d = abs(p)-b;
            return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
        }

        function getOffsetStrength(t:Float, dir:Vec2):Float {
            var d = length(dir/aspect) - t * maxRadius; // SDF of circle
            // Doesn't have to be a circle!!
            // float d = sdBox(dir/aspect, vec2(t * maxRadius));
            
            d *= 1. - smoothstep(0., 0.05, abs(d)); // Mask the ripple
            
            d *= smoothstep(0., 0.05, t); // Smooth intro
            d *= 1. - smoothstep(0.5, 1., t); // Smooth outro
            return d;
          }

        function fragment() {
            var dir = center - calculatedUV;

            var tOffset = 0.05 * sin(t * 3.14);
            var rD = getOffsetStrength(t, dir);
            var gD = getOffsetStrength(t, dir);
            var bD = getOffsetStrength(t, dir);

            dir = normalize(dir);
  
            var r = texture.get(calculatedUV + dir * rD).r;
            var g = texture.get(calculatedUV + dir * gD).g;
            var b = texture.get(calculatedUV + dir * bD).b;
            
            var shading = gD * 8.;
            
            var colour = vec4(r, g, b, 1.);
            colour.rgb += shading;

            // pixelColor = colour;


            // var center = global_position;
            // var ratio = 1; // Width / Height
            // center.x = center.x / screen_size.x;
            // center.x = (center.x - 0.5) / ratio + 0.5;
            // center.y = (screen_size.y - center.y) / screen_size.y;
            // var scaledUV = (calculatedUV - vec2(0.5, 0.0) ) / vec2(ratio, 1.0) + vec2(0.5, 0.0);
            // var mask = (1.0 - smoothstep(size-0.1, size, length(scaledUV - center))) * smoothstep(size-thickness-0.1, size-thickness, length(scaledUV - center));
            // var disp = normalize(calculatedUV - center) * force * mask;
            // pixelColor = texture.get(calculatedUV - disp);

            // var x = sin(calculatedUV.y * 12.56) * 0.02 * smoothstep(calculatedUV.y - 0.3, calculatedUV.y, t);
            // var y = sin(calculatedUV.x * 12.56) * 0.02;
            // var offset = calculatedUV;
            // offset.x = x;
            // offset.y = y;
            // var c = texture.get(calculatedUV + offset);
            // pixelColor =  vec4(c.r, c.g, c.b, 1.0);



            // var st = calculatedUV;
            // var aspect_ratio = 1;
            // var aspect_ratio = screenSize.y / screenSize.x;
            // var scaled_st = (st -vec2(0.0, 0.5)) / vec2(1.0, aspect_ratio) + vec2(0,0.5);
            // var dist_center = scaled_st - center;
            // var mask =  (1.0 - smoothstep(radius - feather, radius, length(dist_center))) * smoothstep(radius - width - feather, radius - width, length(dist_center));
            // var offset = normalize(dist_center) * strength * mask;
	        // var biased_st = scaled_st - offset;
            // var abber_vec = offset * aberration * mask;
            // var final_st = st * (1.0 - mask) + biased_st * mask;

            // var red = texture.get(final_st + abber_vec);
	        // var blue = texture.get(final_st - abber_vec);
	        // var ori = texture.get(final_st);

            pixelColor = vec4(1, 0 , 0, 1.0);
        }
    }
}


class MyParent extends Drawable {

	public function new(p:h2d.Object) {
		super(p);
    }

}

class LightingTestScene extends AbstractScene {
    
    // private final fog:h2d.Bitmap;
    // private final fogShader:FogOfWarShader;
    private final hero:h2d.Bitmap;
    private var t = 0.0;

    private var viewConeAngle = 30;
    private var viewConeLength = 800;

    final waveShader:WaveShader;

	public function new() {
		super();

        final parent = new MyParent(this);

        hero = new h2d.Bitmap(h2d.Tile.fromColor(0xFF0000, 100, 100).center(), parent);
        hero.setPosition(1000, 1000);

        var objectX = 100;
        var objectY = 100;

        for (x in 0...8) {
            for (y in 0...8) {
                final bmp = new h2d.Bitmap(h2d.Tile.fromColor(0x0037FF, 100, 100), parent);
                bmp.setPosition(objectX, objectY);
                objectX += 200;
            }
            objectX = 100;
            objectY += 200;
        }

        // fog = new h2d.Bitmap(h2d.Tile.fromColor(0x040404, 2000, 2000), this);
        // fogShader = new FogOfWarShader();
        // fogShader.texture = fog.tile.getTexture();
        // fogShader.radius = 200;
        // fogShader.playerSize.x = 100;
        // fogShader.playerSize.y = 100;
        // fogShader.fogSize.x = 2000;
        // fogShader.fogSize.y = 2000;
        // fog.addShader(fogShader);

        camera.scale(0.7, 0.7);

        // final water = new h2d.Bitmap(hxd.Res.water.toTile(), parent);
        // water.setScale(5);

        waveShader = new WaveShader();

        // waveShader.global_position.x = 0.1;
        // waveShader.global_position.y = 0.1;
        // waveShader.screen_size.x = 0.2;
        // waveShader.screen_size.y = 0.2;
        // waveShader.force = 1.0;
        // waveShader.size = 0.3;
        // waveShader.thickness = 0.1;


        // waveShader.screenSize.x = 1;
        // waveShader.screenSize.y = 1;
        // waveShader.center.x = 0.1;
        // waveShader.center.y = 0.1;
        // waveShader.texture = water.tile.getTexture();
        waveShader.aspect.x = 1;
        waveShader.aspect.y = 1;
        waveShader.center.x = 0.5;
        waveShader.center.y = 0.5;

        // filter = new h2d.filter.Shader(waveShader);

        parent.addShader(waveShader);

        // @param var strength:Float = 0.08;
        // @param var radius:Float = 0.25;
        // @param var center:Vec2;



        // waveShader.texture = ;
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
        hero.rotation += 1 * dt;

        // fogShader.playerPos.x = hero.x;
        // fogShader.playerPos.y = hero.y;

        waveShader.t += 0.01;


        // waveShader.size += 0.01;
        // waveShader.radius += 0.01;
        // waveShader.center.y += 0.01;

        // final viewCone = calculateViewCone();
        // fogShader.trianglePointA.x = viewCone.center.x; 
        // fogShader.trianglePointA.y = viewCone.center.y; 
        // fogShader.trianglePointB.x = viewCone.leftSide.x; 
        // fogShader.trianglePointB.y = viewCone.leftSide.y; 
        // fogShader.trianglePointC.x = viewCone.rightSide.x; 
        // fogShader.trianglePointC.y = viewCone.rightSide.y; 
	}

    public function absRender(e:Engine) {
        debugGraphics.clear();

        final viewCone = calculateViewCone();

        GraphicsUtils.DrawLine(debugGraphics, viewCone.center.x, viewCone.center.y, viewCone.leftSide.x, viewCone.leftSide.y, Colors.GreenColor);
        GraphicsUtils.DrawLine(debugGraphics, viewCone.center.x, viewCone.center.y, viewCone.rightSide.x, viewCone.rightSide.y, Colors.GreenColor);
        GraphicsUtils.DrawLine(debugGraphics, viewCone.leftSide.x, viewCone.leftSide.y, viewCone.rightSide.x, viewCone.rightSide.y, Colors.GreenColor);
    }
    
    public function absDestroy() {
    }

    private function calculateViewCone() {
        final viewConeHalfAngle = viewConeAngle / 2;
        final center = new Point(hero.x, hero.y);
        final leftSide = MathUtils.rotatePointAroundCenter(center.x + viewConeLength, center.y, center.x, center.y, MathUtils.degreeToRads(-viewConeHalfAngle) + hero.rotation);
        final rightSide = MathUtils.rotatePointAroundCenter(center.x + viewConeLength, center.y, center.x, center.y, MathUtils.degreeToRads(viewConeHalfAngle) + hero.rotation);

        return {
            center: center,
            leftSide: leftSide,
            rightSide: rightSide,
        }
    }

}
