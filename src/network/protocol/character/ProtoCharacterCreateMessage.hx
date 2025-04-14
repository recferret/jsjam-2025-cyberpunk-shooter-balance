package network.protocol.character;

import engine.impl.types.CharacterTypes.CharacterEntity;

typedef ProtoCharacterCreateBody = {
    characters:Array<CharacterEntity>,
};

class ProtoCharacterCreateMessage extends WsBaseMsg<ProtoCharacterCreateBody> {
    
    public static final MSG = 'character-create-message';

    public function new(body:ProtoCharacterCreateBody) {
        super(ProtoCharacterCreateMessage.MSG, body);
    }

}