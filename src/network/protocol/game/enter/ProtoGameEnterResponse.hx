package network.protocol.game.enter;

import engine.impl.types.CharacterTypes.CharacterEntity;

typedef ProtoGameEnterResponseBody = {
    characters:Array<CharacterEntity>,
};

class ProtoGameEnterResponse extends WsBaseMsg<ProtoGameEnterResponseBody> {
    
    public static final MSG = 'enter-game-response';

    public function new(body:ProtoGameEnterResponseBody) {
        super(ProtoGameEnterResponse.MSG, body);
    }

}