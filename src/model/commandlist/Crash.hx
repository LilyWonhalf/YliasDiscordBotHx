package model.commandlist;

import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class Crash implements ICommandDefinition {
    public var paramsUsage = '';
    public var description = L.a.n.g('model.commandlist.crash.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;
        client.sendMessage(msg.channel, L.a.n.g('model.commandlist.crash.process.speech'));
        untyped __js__('setTimeout(() => crash++, 1000)');
    }
}
