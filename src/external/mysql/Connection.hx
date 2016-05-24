package external.mysql;

import haxe.extern.EitherType;

@:native('(require("mysql")).createConnection')
extern class Connection {
    public var _protocol: ConnectionProtocol;

    public function new(info: ConnectionInfo): Void;
    public function connect(?callback: Void->Void): Void;
    public function query(query: String, ?valuesOrCallback: EitherType<Array<String>, QueryCallback>, ?callback: QueryCallback): Void;
    public function end(?callback: Void->Void): Void;
}

typedef ConnectionInfo = {
    host: String,
    user: String,
    password: String,
    database: String
}
typedef QueryCallback = Dynamic->Array<Dynamic>->Void;
typedef QuerySingleResultCallback = Dynamic->Dynamic->Void;
typedef ConnectionProtocol = {
    _ended: Bool
}
