package model.entity;

import nodejs.NodeJS;
import external.discord.client.Client;
import model.Entity.EntityProperties;
import utils.Logger;

class User extends Entity {
    public static var properties: EntityProperties = {
        tableName: 'user',
        tableColumns: [
            {
                name: 'id',
                mappedBy: 'id',
                primary: true
            },
            {
                name: 'name',
                mappedBy: 'name',
                primary: false
            }
        ]
    };

    public var id: Int;
    public var name: String;

    public static function registerUsers(): Void {
        Db.instance.getAll('SELECT id FROM ' + properties.tableName, null, cast function(err: Dynamic, results: Array<Dynamic>) {
            if (err != null) {
                Logger.exception(err);
            } else {
                var client: Client = NodeJS.global.client;
                var ids = new Array<String>;

                for (result in results) {
                    ids.push(result.id);
                }

                for (server in client.servers) {
                    for (user in server.members) {
                        if (ids.indexOf(user.id) < 0) {
                            var newUser = new User();

                            newUser.id = user.id;
                            newUser.name = user.name;
                            newUser.save();

                            ids.push(user.id);
                        }
                    }
                }
            }
        });
    }
}
