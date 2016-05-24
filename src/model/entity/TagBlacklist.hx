package model.entity;

import config.Config;
import model.Entity.EntityProperties;
import utils.Logger;

class TagBlacklist extends Entity {
    public static var properties: EntityProperties = {
        tableName: 'tag_blacklist',
        tableColumns: [
            {
                name: 'id_server',
                mappedBy: 'idServer',
                primary: true
            },
            {
                name: 'tag',
                mappedBy: 'tag',
                primary: true
            }
        ]
    };

    public var idServer: String;
    public var tag: String;

    public static function getAll(idServer: String, callback: Dynamic->Array<String>->Void): Void {
        var query: String = 'SELECT DISTINCT tag FROM tag_blacklist WHERE id_server = ?';
        var values = new Array<String>();

        values.push(idServer);

        if (idServer != Config.KEY_ALL) {
            query += ' OR id_server = ?';
            values.push(Config.KEY_ALL);
        }

        Db.instance.query(query, values, cast function(err: Dynamic, results: Array<Dynamic>) {
            if (err != null) {
                Logger.exception(err);
                callback(err, null);
            } else {
                var parsedResults = new Array<String>();

                for (result in results) {
                    parsedResults.push(result.tag.toLowerCase());
                }

                callback(err, parsedResults);
            }
        });
    }
}
