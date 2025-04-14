package game.impl.scene.impl.game;

import engine.impl.EngineDebugConfig;

class GameUiScene extends h2d.Scene {

    final fui:h2d.Flow;

	final debugModeText:h2d.Text;

	// final currentSpreadText:h2d.Text;

    public function new() {
        super();

        // scale(3);

        fui = new h2d.Flow(this);
		fui.layout = Vertical;
		fui.verticalSpacing = 5;
		fui.padding = 10;

		debugModeText = addStyledText(20, 20, 6, Left, Colors.WhiteColor);
		fui.addChild(debugModeText);

        // addSlider(fui, 'Speed', function() return FswDebugConfig.HeroSpeed, function(v) FswDebugConfig.HeroSpeed = v, 200, 1000);
        // addSlider(fui, 'Move delay', function() return FswDebugConfig.HeroMoveDelay, function(v) FswDebugConfig.HeroMoveDelay = v, 0.01, 0.2);

		// final fuiSpreadSteps = new h2d.Flow(fui);
		// fuiSpreadSteps.layout = Horizontal;
		// fuiSpreadSteps.horizontalSpacing = 10;
		// fuiSpreadSteps.padding = 10;

		// addSlider(fuiSpreadSteps, 'Spread steps', function() return FswDebugConfig.HeroSpreadSteps, function(v) FswDebugConfig.HeroSpreadSteps = Std.int(v), 1, 50);
		// currentSpreadText = addText(fuiSpreadSteps, 'Spread step: 1');

		// addSlider(fui, 'Spread decrease MS', function() return FswDebugConfig.HeroSpreadDecreaseMS, function(v) FswDebugConfig.HeroSpreadDecreaseMS = Std.int(v), 10, 1000);
		// addSlider(fui, 'Spread step angle', function() return FswDebugConfig.HeroSpreadAngleFactor, function(v) FswDebugConfig.HeroSpreadAngleFactor = Std.int(v), 1, 5);

		// addSlider(fui, 'Weapon range', function() return FswDebugConfig.HeroWeaponRange, function(v) FswDebugConfig.HeroWeaponRange = Std.int(v), 300, 1500);
		// addSlider(fui, 'Bullet speed', function() return FswDebugConfig.HeroWeaponBulletSpeed, function(v) FswDebugConfig.HeroWeaponBulletSpeed = Std.int(v), 500, 2500);
    }

	public function update(debugMode:Bool) {
		debugModeText.text = debugMode ? 'Debug active. Press Z to disable it.' : 'Debug inactive. Pres Z to enable debug mode.';

		// currentSpreadText.text = 'Spread step: ' + FswDebugConfig.CurrentHeroSpreadStep;
	} 

    function getFont() {
		return hxd.res.DefaultFont.get();
	}

    function addStyledText(x:Float, y:Float, scale:Float, textAlign:h2d.Text.Align, textColor:Int) {
        final font = getFont();
        final text = new h2d.Text(font);
        text.textColor = textColor;
        text.dropShadow = { dx : 0.5, dy : 0.5, color : 0x0B0903, alpha : 0.8 };
        text.textAlign = textAlign;
        text.setScale(scale);
        text.setPosition(x, y);
        return text;
    }

	function addText(parent:h2d.Flow, text="") {
		var tf = new h2d.Text(getFont(), parent);
		tf.text = text;
		return tf;
	}

    function addSlider(parent:h2d.Flow, label : String, get : Void -> Float, set : Float -> Void, min : Float = 0., max : Float = 1. ) {
		var f = new h2d.Flow(parent);

		f.horizontalSpacing = 5;

		var tf = new h2d.Text(getFont(), f);
		tf.text = label;
		tf.maxWidth = 70;
		tf.textAlign = Right;

		var sli = new h2d.Slider(100, 10, f);
		sli.minValue = min;
		sli.maxValue = max;
		sli.value = get();

		var tf = new h2d.TextInput(getFont(), f);
		tf.text = "" + hxd.Math.fmt(sli.value);
		sli.onChange = function() {
			set(sli.value);
			tf.text = "" + hxd.Math.fmt(sli.value);
			f.needReflow = true;
		};
		tf.onChange = function() {
			var v = Std.parseFloat(tf.text);
			if( Math.isNaN(v) ) return;
			sli.value = v;
			set(v);
		};
		return sli;
	}
}