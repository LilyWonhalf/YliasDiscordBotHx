package model.commandlist;

import utils.DiscordUtils;
import external.discord.channel.TextChannel;
import external.discord.user.User;
import external.discord.channel.PMChannel;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class GetUserId implements ICommandDefinition {
    public var paramsUsage = '';
    public var description = L.a.n.g('model.commandlist.getuserid.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;

        if (args.length < 1) {
            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.getuserid.process.no_args', cast [msg.author]));
        } else {
            var userlist: Array<User>;

            if (msg.channel.isPrivate) {
                var channel: PMChannel = cast msg.channel;
                userlist = [client.user, channel.recipient];
            } else {
                var channel: TextChannel = cast msg.channel;
                userlist = channel.server.members;
            }

            var user = DiscordUtils.getUserFromSearch(userlist, args.join(' '));

            if (user != null) {
                if (user.id == client.user.id) {
                    client.sendMessage(msg.channel, L.a.n.g('model.commandlist.getuserid.process.answer_panic', cast [user.username, cast msg.author, user.id]));
                } else {
                    client.sendMessage(msg.channel, L.a.n.g('model.commandlist.getuserid.process.answer', cast [cast msg.author, user.username, user.id]));
                }
            } else {
                client.sendMessage(msg.channel, L.a.n.g('model.commandlist.getuserid.process.not_found', cast [msg.author]));
            }
        }
    }
}
