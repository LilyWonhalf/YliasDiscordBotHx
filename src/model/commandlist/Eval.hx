package model.commandlist;

import utils.Logger;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class Eval implements ICommandDefinition {
    public var paramsUsage = ' (javascript command)';
    public var description = L.a.n.g('model.commandlist.eval.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;
        var output: String;
        var Db = Db.instance;

        Logger.info('User ' + msg.author.username + ' (' +  msg.author.id + ') executed eval with argument(s) "' + args.join(' ') + '".');

        try {
            output = untyped __js__('eval(args.join(\' \'))');
        } catch (e: Dynamic) {
            Logger.exception(e);
            output = L.a.n.g('model.commandlist.eval.process.exception', cast [msg.author]);
        }

        client.sendMessage(msg.channel, output);
    }
}
