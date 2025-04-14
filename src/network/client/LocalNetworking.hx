package network.client;

import engine.base.types.EntityTypes.EntityType;
import engine.base.types.InputTypes.InputCommand;
import engine.base.types.InputTypes.PlayerInputCommand;

import game.impl.scene.impl.game.GameScene;

import network.client.AbstractNetworking.NetworkMode;
import network.client.WsClientEvents.WsClientEventListener;

import network.protocol.game.enter.ProtoGameEnterRequest;
import network.protocol.input.ProtoInputRequest;

class LocalNetworking extends AbstractNetworking {

    public function new() {
        super(NetworkMode.Local);

        GameScene.gameEngine.setPostUpdateCallback(function callback() {
            WsClientEventListener.instance.notifyGameStateEvent({
                characters: GameScene.gameEngine.getWorldState(),
            });
        });
    }

    function gameEnterImpl(request:ProtoGameEnterRequest) {
        GameScene.gameEngine.createCharacter({
            x: 400,
            y: 200,
            entityType: EntityType.Cyberpunk,
            ownerId: request.body.playerId,
            aiControlled: false,
        });

        WsClientEventListener.instance.notifyGameEnterResponseEvent({
            characters: GameScene.gameEngine.getWorldState(),
        });
    }

    function inputImpl(request:ProtoInputRequest) {
        // final inputCommand = new PlayerInputCommand();
        // inputCommand.setPlayerId(request.body.playerId);
        // inputCommand.setInputCommand(request.body.command);
        // inputCommand.setAngle(request.body.angle);

        // GameScene.gameEngine.addInputCommand(inputCommand);
    }
}