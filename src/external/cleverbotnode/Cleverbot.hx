package external.cleverbotnode;

@:native('(require("cleverbot-node"))')
extern class Cleverbot {
    public static var cookies: Dynamic;
    public static var default_params: Dynamic;
    public static var parserKeys: Array<String>;

    public static var params: Dynamic;

    public static function prepare(callback: Void->Void): Void;
    public static function encodeParams(params: Dynamic): String;
    public static function digest(body: Dynamic): Dynamic;

    public function new(): Void;
    public function write(message: String, callback: Dynamic): Void;
}
