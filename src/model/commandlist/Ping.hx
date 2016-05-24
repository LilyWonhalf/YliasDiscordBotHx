package model.commandlist;

import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class Ping implements ICommandDefinition {
    public var paramsUsage = '';
    public var description = L.a.n.g('model.commandlist.ping.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;
        client.sendMessage(msg.channel, L.a.n.g('model.commandlist.ping.process.answer', cast [msg.author]));
    }
}
