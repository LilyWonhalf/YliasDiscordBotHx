package model.commandlist;

import utils.ArrayUtils;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class Hug implements ICommandDefinition {
    public var paramsUsage = '*(who)*';
    public var description = L.a.n.g('model.commandlist.hug.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;
        var target: String = msg.author.mention();
        var hugs: Array<String>;
        var hug: String;

        if (args.length > 0) {
            target = args.join(' ');
        }

        if (target.indexOf(client.user.id) > -1) {
            hugs = [
                L.a.n.g('model.commandlist.hug.process.self_hug.1'),
                L.a.n.g('model.commandlist.hug.process.self_hug.2'),
                L.a.n.g('model.commandlist.hug.process.self_hug.3')
            ];
        } else {
            hugs = [
                L.a.n.g('model.commandlist.hug.process.hug.1', cast [target]),
                L.a.n.g('model.commandlist.hug.process.hug.2', cast [target]),
                L.a.n.g('model.commandlist.hug.process.hug.3', cast [target]),
                L.a.n.g('model.commandlist.hug.process.hug.4', cast [target]),
                L.a.n.g('model.commandlist.hug.process.hug.5', cast [target]),
                L.a.n.g('model.commandlist.hug.process.hug.6', cast [target]),
                L.a.n.g('model.commandlist.hug.process.hug.7', cast [target]),
                L.a.n.g('model.commandlist.hug.process.hug.8', cast [target]),
                L.a.n.g('model.commandlist.hug.process.hug.9', cast [target])
            ];
        }

        hug = ArrayUtils.random(hugs);

        client.sendMessage(msg.channel, hug);
    }
}
