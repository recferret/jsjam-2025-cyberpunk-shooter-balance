package network.client;

import haxe.Json;
import haxe.net.WebSocket;

import network.client.WsClientEvents.WsClientEventListener;
import network.protocol.character.ProtoCharacterCreateMessage;
import network.protocol.character.ProtoCharacterDeleteMessage;
import network.protocol.input.ProtoInputMessage;
import network.protocol.game.enter.ProtoGameEnterResponse;

class WsClient {

    private final ws:WebSocket;

    public function new() {
        ws = WebSocket.create("ws://localhost:8000");
        ws.onopen = function() {
            trace('opened');
        };
        ws.onmessageString = function(message) {
            final baseMessage = Json.parse(message);

            switch (baseMessage.msg) {
                case ProtoGameEnterResponse.MSG:
                    final messageBody = new ProtoGameEnterResponse({
                        characters: baseMessage.body.characters,
                    });
                    WsClientEventListener.instance.notifyGameEnterResponseEvent(messageBody.body);
                case ProtoInputMessage.MSG:
                    final messageBody = new ProtoInputMessage({
                        playerId: baseMessage.body.playerId,
                        command: baseMessage.body.command,
                        angle: baseMessage.body.angle,
                    });
                    WsClientEventListener.instance.notifyInputEvent(messageBody.body);
                case ProtoCharacterCreateMessage.MSG:
                    final messageBody = new ProtoCharacterCreateMessage({
                        characters: baseMessage.body.characters,
                    });
                    WsClientEventListener.instance.notifyCharacterCreateEvent(messageBody.body);
                case ProtoCharacterDeleteMessage.MSG:
                    final messageBody = new ProtoCharacterDeleteMessage({
                        characterIds: baseMessage.body.characterIds,
                    });
                    WsClientEventListener.instance.notifyCharacterDeleteEvent(messageBody.body);
                default:
                    trace('Unknown message type');
            }
        };
    }

    public function sendString(s:String) {
        ws.sendString(s);
    }
}