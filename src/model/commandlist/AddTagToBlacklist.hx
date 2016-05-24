package model.commandlist;

import external.discord.channel.TextChannel;
import model.entity.TagBlacklist;
import StringTools;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class AddTagToBlacklist implements ICommandDefinition {
    public var paramsUsage = '(tag) *(server id)*';
    public var description = L.a.n.g('model.commandlist.addtagtoblacklist.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;

        if (args.length > 0) {
            var tag: String = StringTools.trim(args[0]);
            var idServer: String;

            if (args.length > 1 && StringTools.trim(args[1]).length > 0) {
                idServer = StringTools.trim(args[1]);
            } else {
                if (msg.channel.isPrivate) {
                    idServer = '0';
                } else {
                    var channel: TextChannel = cast msg.channel;

                    idServer = channel.server.id;
                }
            }

            var newTag: TagBlacklist = new TagBlacklist();

            newTag.idServer = idServer;
            newTag.tag = tag;

            newTag.save(function (err: Dynamic) {
                if (err != null) {
                    client.sendMessage(msg.channel, L.a.n.g('model.commandlist.addtagtoblacklist.fail', cast [msg.author, err]));
                } else {
                    client.sendMessage(msg.channel, L.a.n.g('model.commandlist.addtagtoblacklist.success', cast [msg.author]));
                }
            });
        } else {
            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.addtagtoblacklist.wrong_format', cast [msg.author]));
        }
    }
}
