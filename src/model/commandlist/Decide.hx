package model.commandlist;

import utils.Humanify;
import utils.ArrayUtils;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class Decide implements ICommandDefinition {
    public var paramsUsage = '';
    public var description = L.a.n.g('model.commandlist.decide.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;

        args = args.join(' ').split(' ' + L.a.n.g('model.commandlist.decide.process.split') + ' ');

        if (args.length > 1) {
            var picked = ArrayUtils.random(args);
            var sentence = Humanify.getChoiceDeliverySentence(picked);

            client.sendMessage(msg.channel, msg.author + ' => ' + sentence);
        } else {
            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.decide.process.wrong_format', cast [msg.author]));
        }
    }
}
