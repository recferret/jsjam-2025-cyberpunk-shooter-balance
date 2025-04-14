package network.client;

import network.protocol.game.enter.ProtoGameEnterResponse.ProtoGameEnterResponseBody;
import network.protocol.character.ProtoCharacterCreateMessage.ProtoCharacterCreateBody;
import network.protocol.character.ProtoCharacterDeleteMessage.ProtoCharacterDeleteBody;
import network.protocol.game.state.ProtoGameStateMessage.ProtoGameStateBody;
import network.protocol.input.ProtoInputMessage.ProtoInputMessageBody;

interface GameEnterResponseHandler {
	function gameEnterResponse(body:ProtoGameEnterResponseBody):Void;
}

interface CharacterCreateHandler {
	function characterCreate(body:ProtoCharacterCreateBody):Void;
}

interface CharacterDeleteHandler {
	function characterDelete(body:ProtoCharacterDeleteBody):Void;
}

interface GameStateHandler {
	function gameState(body:ProtoGameStateBody):Void;
}

interface InputHandler {
	function input(body:ProtoInputMessageBody):Void;
}

class WsClientEventListener {

	public static final instance:WsClientEventListener = new WsClientEventListener();

    private var gameEnterResponseHandler:GameEnterResponseHandler;
    private var characterCreateHandler:CharacterCreateHandler;
    private var characterDeleteHandler:CharacterDeleteHandler;
    private var gameStateHandler:GameStateHandler;
    private var inputHandler:InputHandler;

	private function new() {}

	// Game enter

	public function subscribeForGameEnterResponseEvent(gameEnterResponseHandler:GameEnterResponseHandler) {
		this.gameEnterResponseHandler = gameEnterResponseHandler;
	}

	public function notifyGameEnterResponseEvent(body:ProtoGameEnterResponseBody) {
		this.gameEnterResponseHandler.gameEnterResponse(body);
	}

	// Character create

	public function subscribeForCharacterCreateEvent(characterCreateHandler:CharacterCreateHandler) {
		this.characterCreateHandler = characterCreateHandler;
	}
	
	public function notifyCharacterCreateEvent(body:ProtoCharacterCreateBody) {
		this.characterCreateHandler.characterCreate(body);
	}

	// Character create

	public function subscribeForCharacterDeleteEvent(characterDeleteHandler:CharacterDeleteHandler) {
		this.characterDeleteHandler = characterDeleteHandler;
	}
		
	public function notifyCharacterDeleteEvent(body:ProtoCharacterDeleteBody) {
		this.characterDeleteHandler.characterDelete(body);
	}

	// Game state

	public function subscribeForGameStateEvent(gameStateHandler:GameStateHandler) {
		this.gameStateHandler = gameStateHandler;
	}

	public function notifyGameStateEvent(body:ProtoGameStateBody) {
		this.gameStateHandler.gameState(body);
	}

	// Input

	public function subscribeForInputEvent(inputHandler:InputHandler) {
		this.inputHandler = inputHandler;
	}

	public function notifyInputEvent(body:ProtoInputMessageBody) {
		this.inputHandler.input(body);
	}
}