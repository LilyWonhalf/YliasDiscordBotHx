package yliasdiscordbothx.model;

import nodejs.NodeJS;
import discordbothx.log.Logger;
import haxe.Timer;
import yliasdiscordbothx.external.mysql.Connection;

class Db {
    public static var instance(get, null): Db;

    private var db: Connection;
    private var pool: Array<DelayedQuery>;
    private var connectionRestoring: Bool;
    private var connectionRetries: Int;
    private var logged: Bool;

    public static function get_instance(): Db {
        if (instance == null){
            instance = new Db();
        }

        return instance;
    }

    public function get(query: String, values: Array<Dynamic>, callback: Dynamic->Dynamic->Void) {
        if (isConnectionRunning()) {
            db.query(query + ' LIMIT 1', cast sanitizeValues(values), cast function (err: Dynamic, results: Array<Dynamic>, fields: Array<String>) {
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
            db.query(query, cast sanitizeValues(values), callback);
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
            db.query(query, cast function (err: Dynamic, results: Array<Dynamic>) {
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
        db.end(callback);
    }

    public function isConnectionRunning(): Bool {
        return !db._protocol._ended;
    }

    public function addQueryToPool(query: DelayedQuery): Void {
        pool.push(query);
        restoreConnection();
    }

    public function restoreConnection(): Void {
        if (!connectionRestoring) {
            Logger.warning('Connection to database lost, trying to reconnect...');
            connectionRestoring = true;
            connectionRetries = 3;
            close(connectionClosedHandler);
        }
    }

    public function flushPool(): Void {
        connectionRestoring = false;

        if (pool.length > 0) {
            var query = pool.shift();

            do {
                Reflect.callMethod(this, Reflect.field(Db.instance, query.method), query.args);

                if (pool.length > 0) {
                    query = pool.shift();
                }
            } while (pool.length > 0);
        }
    }

    private function new(): Void {
        Logger.info('Initiating database connection and keep-alive process...');

        initializeConnection();
        logged = false;
        db.connect(keepConnectionAlive);
        pool = new Array<DelayedQuery>();
        connectionRestoring = false;
    }

    private function keepConnectionAlive(): Void {
        db.query('SELECT 1');

        if (logged == false) {
            Logger.info('Database connection keep-alive initiated.');
            logged = true;
        }

        Timer.delay(keepConnectionAlive, 20000);
    }

    private function initializeConnection(): Void {
        db = new Connection({
            host : Bot.instance.authDetails.DB_HOST,
            user : Bot.instance.authDetails.DB_USER,
            password : Bot.instance.authDetails.DB_PASSWORD,
            database : Bot.instance.authDetails.DB_NAME
        });
    }

    private function connectionClosedHandler(): Void {
        initializeConnection();
        db.connect(connectionEstablishedHandler);
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

            if (connectionRetries > 0) {
                connectionRetries--;

                Timer.delay(function() {
                    Logger.notice('Trying to connect another time (' + connectionRetries + ' left)...');
                    db.connect(connectionEstablishedHandler);
                }, 1000);
            } else {
                Logger.error('Reconnection failed. Ending process...');
                close(connectionClosedAfterFatalErrorHandler);
            }
        }
    }

    private function sanitizeValues(values: Array<Dynamic>): Array<Dynamic> {
        var ret = null;

        if (values != null) {
            ret = values.map(sanitizeValue);
        }

        return ret;
    }

    private function sanitizeValue(value: Dynamic): Dynamic {
        var newValue: Dynamic = value;

        if (Std.is(value, String)) {
            newValue = ~/[\u0800-\uFFFF]/g.replace(value, '');
        }

        return newValue;
    }
}

typedef DelayedQuery = {
    method: String,
    args: Array<Dynamic>
}
