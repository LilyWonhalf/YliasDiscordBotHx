package model.commandlist;

import utils.Logger;
import model.entity.TagBlacklist;
import utils.DiscordUtils;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class GetBlacklistedTags implements ICommandDefinition {
    public var paramsUsage = '*(server id)*';
    public var description = L.a.n.g('model.commandlist.getblacklistedtags.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;
        var serverId: String = DiscordUtils.getServerIdFromMessage(msg);

        if (args.length > 0 && StringTools.trim(args[0]).length > 0) {
            serverId = StringTools.trim(args[0]);
        }

        TagBlacklist.getAll(serverId, function(err: Dynamic, tags: Array<String>) {
            if (err != null) {
                Logger.exception(err);
                client.sendMessage(msg.channel, L.a.n.g('model.commandlist.getblacklistedtags.process.fail', cast [cast msg.author]));
            } else {
                client.sendMessage(msg.channel, L.a.n.g('model.commandlist.getblacklistedtags.process.success', cast [cast msg.author, tags.join('\n')]));
            }
        });
    }
}
