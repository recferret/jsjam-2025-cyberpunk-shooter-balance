import haxe.net.WebSocketServer;

import network.server.WsServerEvents.GameEnterHandler;
import network.server.WsServerEvents.InputHandler;
import network.server.WsServerEvents.WsServerEventListener;
import network.server.WsHandler;
import network.protocol.character.ProtoCharacterCreateMessage;
import network.protocol.character.ProtoCharacterDeleteMessage;
import network.protocol.game.enter.ProtoGameEnterRequest.ProtoGameEnterBody;
import network.protocol.game.enter.ProtoGameEnterResponse;
import network.protocol.input.ProtoInputRequest.ProtoInputRequestBody;
import network.protocol.input.ProtoInputMessage;

import engine.base.types.EntityTypes.EntityType;
import engine.base.types.InputTypes.InputCommand;
import engine.base.types.InputTypes.PlayerInputCommand;
import engine.base.EngineConfig;

import engine.fsw.entity.base.character.FswCharacterEntity;
import engine.fsw.entity.base.projectile.FswProjectileEntity;
import engine.fsw.events.character.CreateCharacterEventListener;
import engine.fsw.events.character.DeleteCharacterEventListener;
import engine.fsw.events.projectile.CreateProjectileEventListener;
import engine.fsw.events.projectile.DeleteProjectileEventListener;
import engine.fsw.FswGameEngine;

class ServerMain
	// Game engine events
	implements CreateCharacterEventHandler
	implements DeleteCharacterEventHandler
    implements CreateProjectileEventHandler
    implements DeleteProjectileEventHandler
	// WS events
	implements GameEnterHandler
	implements InputHandler {

	private final webSockerServer:WebSocketServer;
	private final socketByPlayerId = new Map<String, WsHandler>();

	private final fswGameEngine:FswGameEngine;

	private var playersJoined = new Array<String>();

    public function new() {
		// Ws events
		WsServerEventListener.instance.subscribeForGameEnterEvent(this);
		WsServerEventListener.instance.subscribeForInputEvent(this);

		// Engine events
		CreateCharacterEventListener.instance.subscribe(this);
		DeleteCharacterEventListener.instance.subscribe(this);
		CreateProjectileEventListener.instance.subscribe(this);
		DeleteProjectileEventListener.instance.subscribe(this);

		fswGameEngine = new FswGameEngine();
        fswGameEngine.setPostUpdateCallback(function callback() {
			// Notify new players about world state
			for (playerJoined in playersJoined) {
				final gameEnterResponse = new ProtoGameEnterResponse({
					characters: fswGameEngine.getWorldState(),
				});

				final socket = socketByPlayerId.get(playerJoined);
				if (socket != null) {
					socket.sendString(gameEnterResponse.stringify());
				}
			}

			// Notify rest of players about world state
			for (value in socketByPlayerId) {
				if (playersJoined.length > 0) {
					if (!playersJoined.contains(value.playerId)) {
						final protoCharacterCreateMessage = new ProtoCharacterCreateMessage({
							characters: fswGameEngine.getCharacterEntitiesByOwnerIds(playersJoined),
						});
						value.sendString(protoCharacterCreateMessage.stringify());
					}
				}
				// TODO notify changed
			}
			playersJoined = [];
        });

		final clientHandlers = new Array<WsHandler>();

		webSockerServer = WebSocketServer.create('0.0.0.0', 8000, 100, false, false);

		while (true) {
			try {
				final websocket = webSockerServer.accept();
				if (websocket != null) {
					clientHandlers.push(new WsHandler(websocket));
				}
					
				final toRemove = [];
				for (handler in clientHandlers) {
					if (!handler.update()) {
						toRemove.push(handler);
					}
				}

				for (tr in toRemove) {
					fswGameEngine.deleteCharacterByOwnerId(tr.playerId);
					socketByPlayerId.remove(tr.playerId);
					clientHandlers.remove(tr);
				}
						
				// while (toRemove.length > 0) {
				// 	final wsToRemove = toRemove.pop();
				// 	trace(toRemove);
				// 	// fswGameEngine.deleteCharacterByOwnerId(wsToRemove.playerId);
				// 	socketByPlayerId.remove(wsToRemove.playerId);
				// }
						
				fswGameEngine.gameLoop.manualLoopUpdate();
				Sys.sleep(1 / EngineConfig.TARGET_FPS);
			}
			catch (e:Dynamic) {
				// trace('Error', e);
			}
		}
    }

	static function main() {
		new ServerMain();
    }

	// Client web socket events

	public function gameEnter(body:ProtoGameEnterBody, wsHandler:WsHandler) {
		fswGameEngine.createCharacter({
            x: 900,
            y: 1800,
            entityType: EntityType.Cyberpunk,
            ownerId: body.playerId,
		});

		wsHandler.playerId = body.playerId;
		socketByPlayerId.set(body.playerId, wsHandler);

		// TODO prepare game enter response
		playersJoined.push(body.playerId);
	}

	public function input(body:ProtoInputRequestBody) {
		final playerInputCommand = new PlayerInputCommand();
		playerInputCommand.setPlayerId(body.playerId);
		playerInputCommand.setInputCommand(body.command);
		playerInputCommand.setAngle(body.angle);
		fswGameEngine.addInputCommand(playerInputCommand);

		// TODO broadcast command
		final message = new ProtoInputMessage({
			playerId: body.playerId,
			command: body.command,
			angle: body.angle,
		});
		for (value in socketByPlayerId) {
			if (value.playerId != body.playerId) {
				value.sendString(message.stringify());
			}
		}
	}

	// Game engine events

	public function createCharacterEventHandler(characters:Array<FswCharacterEntity>) {
		trace('createCharacterEventHandler');
	}

	public function deleteCharacterEventHandler(characterIds:Array<String>) {
		trace('deleteCharacterEventHandler 1');

		final message = new ProtoCharacterDeleteMessage({
			characterIds: characterIds,
		});

		for (value in socketByPlayerId) {
			value.sendString(message.stringify());
		}

		trace('deleteCharacterEventHandler 2');
	}

	public function createProjectileEventHandler(projectiles:Array<FswProjectileEntity>) {
		trace('createProjectileEventHandler');
	}

	public function deleteProjectileEventHandler(ids:Array<String>) {
		trace('deleteProjectileEventHandler');
	}

}