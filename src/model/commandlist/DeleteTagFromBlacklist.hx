package model.commandlist;

import external.discord.channel.TextChannel;
import model.entity.TagBlacklist;
import utils.Logger;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class DeleteTagFromBlacklist implements ICommandDefinition {
    public var paramsUsage = '(tag) *(server ID)*';
    public var description = L.a.n.g('model.commandlist.deletetagfromblacklist.description');
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

            var tagToDelete: TagBlacklist = new TagBlacklist();
            var primaryValues = new Map<String, String>();

            primaryValues.set('idServer', idServer);
            primaryValues.set('tag', tag);

            tagToDelete.retrieve(primaryValues, function (found: Bool) {
                if (found) {
                    tagToDelete.remove(function (err: Dynamic) {
                        if (err != null) {
                            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.deletetagfromblacklist.fail', cast [msg.author, err]));
                        } else {
                            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.deletetagfromblacklist.success', cast [msg.author]));
                        }
                    });
                } else {
                    client.sendMessage(msg.channel, L.a.n.g('model.commandlist.deletetagfromblacklist.not_found', cast [msg.author]));
                }
            });
        } else {
            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.deletetagfromblacklist.wrong_format', cast [msg.author]));
        }
    }
}
