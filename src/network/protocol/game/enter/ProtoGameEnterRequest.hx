package network.protocol.game.enter;

typedef ProtoGameEnterBody = {
    playerId:String,
};

class ProtoGameEnterRequest extends WsBaseMsg<ProtoGameEnterBody> {
    
    public static final MSG = 'enter-game-request';

    public function new(body:ProtoGameEnterBody) {
        super(ProtoGameEnterRequest.MSG, body);
    }

}