package model.entity;

import model.Entity.EntityProperties;
import utils.Logger;

class Channel extends Entity {
    public static var properties: EntityProperties = {
        tableName: 'channel',
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

    public static function registerChannels(): Void {
        Db.instance.getAll('SELECT id FROM ' + properties.tableName, null, cast function(err: Dynamic, results: Array<Dynamic>) {
            if (err != null) {
                Logger.exception(err);
            } else {
                var ids = new Array<String>();

                for (result in results) {
                    ids.push(result.id);
                }

                for (channel in Core.instance.getChannels()) {
                    if (ids.indexOf(channel.id) < 0) {
                        var newChannel = new Channel();

                        newChannel.id = channel.id;
                        newChannel.name = channel.name;
                        newChannel.save();

                        ids.push(channel.id);
                    }
                }

                for (channel in Core.instance.getPrivateChannels()) {
                    if (ids.indexOf(channel.id) < 0) {
                        var newChannel = new Channel();

                        newChannel.id = channel.id;
                        newChannel.name = 'Private channel with ' + channel.recipient.username;
                        newChannel.save();

                        ids.push(channel.id);
                    }
                }
            }
        });
    }
}
