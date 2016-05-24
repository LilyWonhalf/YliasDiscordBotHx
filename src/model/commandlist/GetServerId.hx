package model.commandlist;

import external.discord.channel.TextChannel;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class GetServerId implements ICommandDefinition {
    public var paramsUsage = '';
    public var description = L.a.n.g('model.commandlist.getserverid.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;

        if (msg.channel.isPrivate) {
            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.getserverod.process.private_conversation', cast [msg.author]));
        } else {
            var channel: TextChannel = cast msg.channel;

            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.getserverod.process.answer', cast [cast msg.author, channel.server.id]));
        }
    }
}
