package network.server;

import haxe.Json;
import haxe.io.Bytes;
import haxe.net.WebSocket;

import network.server.WsServerEvents.WsServerEventListener;

import network.protocol.game.enter.ProtoGameEnterRequest.ProtoGameEnterRequest;
import network.protocol.input.ProtoInputRequest.ProtoInputRequest;

class WsHandler {
	public var playerId:String;

	private static var nextId = 0;
	private var id = nextId++;
	
    private final websocket:WebSocket;

	public function new(websocket:WebSocket) {
		this.websocket = websocket;
		this.websocket.onopen = onopen;
		this.websocket.onclose = onclose;
		this.websocket.onerror = onerror;
		this.websocket.onmessageBytes = onmessageBytes;
		this.websocket.onmessageString = onmessageString;
	}
	
	public function update():Bool {
		websocket.process();
		return websocket.readyState != Closed;
	}

	public function sendString(s:String) {
		websocket.sendString(s);
	}
	
    function onopen():Void {
		trace('$id:open');
		// _websocket.sendString('Hello from server');
    }

    function onerror(message:String):Void {
		trace('$id:error: $message');
    }

    function onmessageString(message:String):Void {
		final message = Json.parse(message);

		switch (message.msg) {
			case ProtoGameEnterRequest.MSG: {
				final msg = new ProtoGameEnterRequest({
					playerId: message.body.playerId,
				});
				WsServerEventListener.instance.notifyGameEnterEvent(msg.body, this);
			}
			case ProtoInputRequest.MSG: {
				final msg = new ProtoInputRequest({
					playerId: message.body.playerId,
					command: message.body.command,
					angle: message.body.angle,
				});
				WsServerEventListener.instance.notifyInputEvent(msg.body);
			}
			default:
				trace('ERROR, unable to parse client message:');
				trace(message);
		}
    }

    function onmessageBytes(message:Bytes):Void {
		trace('$id:message bytes:' + message.toHex());
		// _websocket.sendBytes(message);
    }

    function onclose(?e : Null<Dynamic>):Void {
		trace('$id:close');
    }
}