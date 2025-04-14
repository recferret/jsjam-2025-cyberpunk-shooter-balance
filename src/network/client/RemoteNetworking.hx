package network.client;

import engine.base.types.InputTypes.InputCommand;
import engine.base.types.InputTypes.PlayerInputCommand;

import game.impl.scene.impl.game.GameScene;

import network.client.AbstractNetworking.NetworkMode;
import network.protocol.game.enter.ProtoGameEnterRequest;
import network.protocol.input.ProtoInputRequest;

class RemoteNetworking extends AbstractNetworking {

    private final wsClient:WsClient;
    var inputsApplied = 0;

    public function new() {
        super(NetworkMode.Remote);

        wsClient = new WsClient();
    }

    function gameEnterImpl(request:ProtoGameEnterRequest) {
        wsClient.sendString(request.stringify());
    }

    function inputImpl(request:ProtoInputRequest) {
        final inputCommand = new PlayerInputCommand();
        inputCommand.setPlayerId(request.body.playerId);
        inputCommand.setInputCommand(request.body.command);
        inputCommand.setAngle(request.body.angle);
        wsClient.sendString(request.stringify());
    }
}