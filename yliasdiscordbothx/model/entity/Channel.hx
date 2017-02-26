package yliasdiscordbothx.model.entity;

import discordhx.channel.VoiceChannel;
import discordhx.channel.GroupDMChannel;
import discordhx.channel.TextChannel;
import discordhx.channel.DMChannel;
import discordhx.channel.ChannelType;
import discordbothx.core.DiscordBot;
import discordbothx.log.Logger;
import yliasdiscordbothx.model.Entity.EntityProperties;

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

                for (channel in DiscordBot.instance.client.channels.array()) {
                    if (ids.indexOf(channel.id) < 0) {
                        var newChannel = new Channel();

                        newChannel.id = channel.id;

                        if (channel.type == ChannelType.DM) {
                            var directChannel: DMChannel = cast channel;

                            newChannel.name = 'Private channel with ' + directChannel.recipient.username;
                        } else {
                            if (channel.type == ChannelType.GROUP) {
                                var groupChannel: GroupDMChannel = cast channel;

                                newChannel.name = groupChannel.name;
                            } else if (channel.type == ChannelType.TEXT) {
                                var textChannel: TextChannel = cast channel;

                                newChannel.name = textChannel.name;
                            } else {
                                var voiceChannel: VoiceChannel = cast channel;

                                newChannel.name = voiceChannel.name;
                            }
                        }

                        newChannel.save();
                        ids.push(channel.id);
                    }
                }
            }
        });
    }
}
