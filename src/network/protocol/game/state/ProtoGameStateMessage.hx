package network.protocol.game.state;

import engine.impl.types.CharacterTypes.CharacterEntity;

typedef ProtoGameStateBody = {
    characters:Array<CharacterEntity>,
};

class ProtoGameStateMessage extends WsBaseMsg<ProtoGameStateBody> {
    
    public static final MSG = 'game-state-message';

    public function new(body:ProtoGameStateBody) {
        super(ProtoGameStateMessage.MSG, body);
    }

}