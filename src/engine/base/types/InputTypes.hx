package engine.base.types;

enum abstract InputCommand(Int) {
    var LookAt = 1;
    var Shoot = 2;
	var Move = 3;
	var Skill = 4;
}

class PlayerInputCommand {
	public var inputCommand:Null<InputCommand>;
	public var playerId:String;
	public var angle:Float;

    public function new() {
    }

	public function setInputCommand(inputCommand:InputCommand) {
		this.inputCommand = inputCommand;
		return this;
	}

	public function setPlayerId(playerId:String) {
		this.playerId = playerId;
		return this;
	}

	public function setAngle(angle:Float) {
		this.angle = angle;
		return this;
	}
}