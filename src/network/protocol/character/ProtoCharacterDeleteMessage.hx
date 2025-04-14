package network.protocol.character;

import engine.impl.types.CharacterTypes.CharacterEntity;

typedef ProtoCharacterDeleteBody = {
    characterIds:Array<String>,
};

class ProtoCharacterDeleteMessage extends WsBaseMsg<ProtoCharacterDeleteBody> {
    
    public static final MSG = 'character-delete-message';

    public function new(body:ProtoCharacterDeleteBody) {
        super(ProtoCharacterDeleteMessage.MSG, body);
    }

}