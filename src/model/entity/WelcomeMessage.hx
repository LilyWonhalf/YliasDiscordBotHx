package model.entity;

import utils.Logger;
import config.Config;
import model.Entity.EntityProperties;

class WelcomeMessage extends Entity {
    public static var properties: EntityProperties = {
        tableName: 'welcome_message',
        tableColumns: [
            {
                name: 'id',
                mappedBy: 'id',
                primary: true
            },
            {
                name: 'message',
                mappedBy: 'message',
                primary: false
            },
            {
                name: 'id_server',
                mappedBy: 'idServer',
                primary: false
            }
        ]
    };

    public var id: Int;
    public var message: String;
    public var idServer: String;

    public static function getForServer(idServer: String, callback: Dynamic->String->Void): Void {
        var query: String = 'SELECT DISTINCT message FROM ' + properties.tableName + ' WHERE id_server = ?';

        Db.instance.get(query, [idServer], cast function(err: Dynamic, result: Dynamic) {
            if (err != null || result == null) {
                callback(err, null);
            } else {
                callback(err, result.message);
            }
        });
    }
}
