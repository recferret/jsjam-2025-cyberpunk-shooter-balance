package network.protocol.input;

import engine.base.types.InputTypes.InputCommand;

typedef ProtoInputRequestBody = {
    playerId:String,
    command:InputCommand,
    ?angle:Float,
};

class ProtoInputRequest extends WsBaseMsg<ProtoInputRequestBody> {
    
    public static final MSG = 'input-request';

    public function new(body:ProtoInputRequestBody) {
        super(ProtoInputRequest.MSG, body);
    }

}