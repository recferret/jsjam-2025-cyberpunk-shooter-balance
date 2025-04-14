package network.protocol;

import haxe.Json;

@:generic
class WsBaseMsg<T> {
    
    public final msg:String;
    public final body:T;

    public function new(msg:String, body:T) {
        this.msg = msg;
        this.body = body;
    }

    public function parse(s:String) {
        return Json.parse(s);
    }

    public function stringify() {
        return Json.stringify({
            msg: msg,
            body: body,
        });
    }

}