package model.entity;

import model.Entity.EntityProperties;
import utils.Logger;

class Joke extends Entity {
    public static var properties: EntityProperties = {
        tableName: 'joke',
        tableColumns: [
            {
                name: 'id',
                mappedBy: 'id',
                primary: true
            },
            {
                name: 'content',
                mappedBy: 'content',
                primary: false
            }
        ]
    };

    public var id: Int;
    public var content: String;

    public static function getRandom(?search: Array<String>, ?callback: Joke->Void): Void {
        var query: String = 'SELECT * FROM ' + properties.tableName + ' ';

        if (search != null && search.length > 0) {
            for (i in 0...search.length) {
                if (i < 1) {
                    query += ' WHERE ';
                } else {
                    query += ' AND ';
                }

                query += 'content LIKE "%' + search[i] + '%"';
            }
        }

        query += ' ORDER BY RAND()';

        Db.instance.get(query, [], cast function(err: Dynamic, row: Dynamic) {
            var output: Joke = null;

            if (row != null) {
                output = new Joke();
                output.id = row.id;
                output.content = row.content;
            }

            if (err) {
                Logger.exception(err);
            }

            callback(output);
        });
    }
}
