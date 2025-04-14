package network.client;

import engine.base.types.InputTypes.PlayerInputCommand;

import network.protocol.game.enter.ProtoGameEnterRequest.ProtoGameEnterRequest;
import network.protocol.input.ProtoInputRequest.ProtoInputRequest;

import game.impl.Game;

enum abstract NetworkMode(String) {
	var Local = 'Local';
	var Remote = 'Remote';
}

abstract class AbstractNetworking {

    public final networkMode:NetworkMode;

    public function new(networkMode:NetworkMode) {
        this.networkMode = networkMode;
    }

    // ABS

    abstract function gameEnterImpl(request:ProtoGameEnterRequest):Void;
    abstract function inputImpl(request:ProtoInputRequest):Void;

    //

    public function gameEnter() {
        final request = new ProtoGameEnterRequest({playerId: Game.PlayerId});
        gameEnterImpl(request);
    }

    public function input(command:PlayerInputCommand) {
        final request = new ProtoInputRequest({
            playerId: command.playerId,
            command: command.inputCommand,
            angle: command.angle,
        });
        inputImpl(request);
    }

}