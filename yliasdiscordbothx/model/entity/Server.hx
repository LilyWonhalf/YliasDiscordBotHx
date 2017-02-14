package yliasdiscordbothx.model.entity;

import discordbothx.core.DiscordBot;
import discordbothx.log.Logger;
import yliasdiscordbothx.model.Entity.EntityProperties;

class Server extends Entity {
    public static var properties: EntityProperties = {
        tableName: 'server',
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

    public static function registerServers(): Void {
        Db.instance.getAll('SELECT id FROM ' + properties.tableName, null, cast function(err: Dynamic, results: Array<Dynamic>) {
            if (err != null) {
                Logger.exception(err);
            } else {
                var ids = new Array<String>();

                for (result in results) {
                    ids.push(result.id);
                }

                for (guild in DiscordBot.instance.client.guilds.array()) {
                    if (ids.indexOf(guild.id) < 0) {
                        var newServer = new Server();

                        newServer.id = guild.id;
                        newServer.name = guild.name;
                        newServer.save();

                        ids.push(guild.id);
                    }
                }
            }
        });
    }
}
