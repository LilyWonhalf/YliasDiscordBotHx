package yliasdiscordbothx.model.entity;

import discordbothx.core.DiscordBot;
import discordbothx.log.Logger;
import yliasdiscordbothx.model.Entity.EntityProperties;

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

    public var id: String;
    public var name: String;

    public static function registerUsers(): Void {
        Db.instance.getAll('SELECT id FROM ' + properties.tableName, null, cast function(err: Dynamic, results: Array<Dynamic>) {
            if (err != null) {
                Logger.exception(err);
            } else {
                var ids = new Array<String>();

                for (result in results) {
                    ids.push(result.id);
                }

                for (user in DiscordBot.instance.client.users.array()) {
                    if (ids.indexOf(user.id) < 0) {
                        var newUser = new User();

                        newUser.id = user.id;
                        newUser.name = user.username;
                        newUser.save();

                        ids.push(user.id);
                    }
                }
            }
        });
    }
}
