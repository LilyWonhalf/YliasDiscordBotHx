package model.commandlist;

import utils.DiscordUtils;
import external.discord.channel.TextChannel;
import external.discord.channel.PMChannel;
import external.discord.user.User;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class Avatar implements ICommandDefinition {
    public var paramsUsage = '';
    public var description = L.a.n.g('model.commandlist.avatar.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;
        var userlist: Array<User> = null;

        if (msg.channel.isPrivate) {
            var channel: PMChannel = cast msg.channel;
            userlist = [client.user, channel.recipient];
        } else {
            var channel: TextChannel = cast msg.channel;
            userlist = channel.server.members;
        }

        var user: User = DiscordUtils.getUserFromSearch(userlist, args.join(' '));

        if (user != null) {
            if (user.id == client.user.id) {
                client.sendMessage(msg.channel, msg.author + ' => ' + user.avatarURL, cast {tts: false}, function(err: Dynamic, sentMessage: Message) {
                    client.sendMessage(msg.channel, L.a.n.g('model.commandlist.avatar.process.client_avatar_author', cast ['https://commons.wikimedia.org/wiki/File:Anthro_vixen_colored.jpg']));
                });
            } else {
                client.sendMessage(msg.channel, msg.author + ' => ' + user.avatarURL);
            }
        } else {
            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.avatar.process.not_found', cast [msg.author]));
        }
    }
}
