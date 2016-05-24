package model.entity;

import nodejs.NodeJS;
import external.discord.client.Client;
import model.Entity.EntityProperties;
import utils.Logger;

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

    public var id: Int;
    public var name: String;

    public static function registerServers(): Void {
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
                    if (ids.indexOf(server.id) < 0) {
                        var newServer = new Server();

                        newServer.id = server.id;
                        newServer.name = server.name;
                        newServer.save();

                        ids.push(server.id);
                    }
                }
            }
        });
    }
}
