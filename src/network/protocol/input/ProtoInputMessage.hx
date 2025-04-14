package network.protocol.input;

import engine.base.types.InputTypes.InputCommand;

typedef ProtoInputMessageBody = {
    playerId:String,
    command:InputCommand,
    ?angle:Float,
};

class ProtoInputMessage extends WsBaseMsg<ProtoInputMessageBody> {
    
    public static final MSG = 'input-message';

    public function new(body:ProtoInputMessageBody) {
        super(ProtoInputMessage.MSG, body);
    }

}