package model;

import nodejs.NodeJS;
import haxe.Timer;
import utils.Logger;
import config.AuthDetails;
import external.mysql.Connection;

class Db {
    public static var instance(get, null): Db;

    private static var _instance: Db;

    private var _db: Connection;
    private var _pool: Array<DelayedQuery>;
    private var _connectionRestoring: Bool;
    private var _connectionRetries: Int;

    public static function get_instance(): Db {
        if (_instance == null){
            _instance = new Db();
        }

        return _instance;
    }

    public function get(query: String, values: Array<Dynamic>, callback: Dynamic->Dynamic->Void) {
        if (isConnectionRunning()) {
            _db.query(query + ' LIMIT 1', cast values, cast function (err: Dynamic, results: Array<Dynamic>, fields: Array<String>) {
                if (err != null) {
                    callback(err, null);
                } else {
                    callback(err, results[0]);
                }
            });
        } else {
            addQueryToPool({
                method: 'get',
                args: [
                    query,
                    callback
                ]
            });
        }
    }

    public function getAll(query: String, values: Array<Dynamic>, callback: Dynamic->Array<Dynamic>->Void) {
        execute(query, values, callback);
    }

    public function query(query: String, values: Array<Dynamic>, callback: Dynamic->Array<Dynamic>->Void) {
        execute(query, values, callback);
    }

    public function execute(query: String, values: Array<Dynamic>, callback: Dynamic->Array<Dynamic>->Void) {
        if (isConnectionRunning()) {
            _db.query(query, cast values, callback);
        } else {
            addQueryToPool({
                method: 'execute',
                args: [
                    query,
                    values,
                    callback
                ]
            });
        }
    }

    public function each(query: String, callback: Dynamic->Dynamic->Void): Void {
        if (isConnectionRunning()) {
            _db.query(query, cast function (err: Dynamic, results: Array<Dynamic>) {
                if (err != null) {
                    callback(err, null);
                } else {
                    for (result in results) {
                        callback(err, result);
                    }
                }
            });
        } else {
            addQueryToPool({
                method: 'each',
                args: [
                    query,
                    callback
                ]
            });
        }
    }

    public function close(?callback: Void->Void): Void {
        _db.end(callback);
    }

    public function isConnectionRunning(): Bool {
        return !_db._protocol._ended;
    }

    public function addQueryToPool(query: DelayedQuery): Void {
        _pool.push(query);
        restoreConnection();
    }

    public function restoreConnection(): Void {
        if (!_connectionRestoring) {
            Logger.warning('Connection to database lost, trying to reconnect...');
            _connectionRestoring = true;
            _connectionRetries = 3;
            close(connectionClosedHandler);
        }
    }

    public function flushPool(): Void {
        _connectionRestoring = false;

        if (_pool.length > 0) {
            var query = _pool.shift();

            do {
                Reflect.callMethod(this, Reflect.field(Db.instance, query.method), query.args);

                if (_pool.length > 0) {
                    query = _pool.shift();
                }
            } while (_pool.length > 0);
        }
    }

    private function new(): Void {
        initializeConnection();
        _db.connect();
        _pool = new Array<DelayedQuery>();
        _connectionRestoring = false;
    }

    private function initializeConnection(): Void {
        _db = new Connection({
            host : AuthDetails.DB_HOST,
            user : AuthDetails.DB_USER,
            password : AuthDetails.DB_PASSWORD,
            database : AuthDetails.DB_NAME
        });
    }

    private function connectionClosedHandler(): Void {
        initializeConnection();
        _db.connect(connectionEstablishedHandler);
    }

    private function connectionClosedAfterFatalErrorHandler(): Void {
        NodeJS.process.exit(1);
    }

    private function connectionEstablishedHandler(): Void {
        if (isConnectionRunning()) {
            Logger.info('Connection success!');
            flushPool();
        } else {
            Logger.error('Reconnection failed.');

            if (_connectionRetries > 0) {
                _connectionRetries--;

                Timer.delay(function() {
                    Logger.notice('Trying to connect another time (' + _connectionRetries + ' left)...');
                    _db.connect(connectionEstablishedHandler);
                }, 1000);
            } else {
                Logger.error('Reconnection failed. Ending process...');
                close(connectionClosedAfterFatalErrorHandler);
            }
        }
    }
}

typedef DelayedQuery = {
    method: String,
    args: Array<Dynamic>
}
