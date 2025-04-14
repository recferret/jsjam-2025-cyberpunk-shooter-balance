package network.server;

import network.protocol.input.ProtoInputRequest.ProtoInputRequestBody;
import network.protocol.game.enter.ProtoGameEnterRequest.ProtoGameEnterBody;

interface GameEnterHandler {
	function gameEnter(body:ProtoGameEnterBody, wsHandler:WsHandler):Void;
}

interface InputHandler {
	function input(body:ProtoInputRequestBody):Void;
}

class WsServerEventListener {

	public static final instance:WsServerEventListener = new WsServerEventListener();

    private var gameEnterListener:GameEnterHandler;
    private var inputHandler:InputHandler;

	private function new() {}

	// Game enter

	public function subscribeForGameEnterEvent(gameEnterListener:GameEnterHandler) {
		this.gameEnterListener = gameEnterListener;
	}

	public function notifyGameEnterEvent(body:ProtoGameEnterBody, wsHandler:WsHandler) {
		this.gameEnterListener.gameEnter(body, wsHandler);
	}

	// Input

	public function subscribeForInputEvent(inputHandler:InputHandler) {
		this.inputHandler = inputHandler;
	}

	public function notifyInputEvent(body:ProtoInputRequestBody) {
		this.inputHandler.input(body);
	}
}