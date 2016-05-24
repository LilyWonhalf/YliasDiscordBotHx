package model.commandlist;

import utils.Logger;
import model.entity.Joke;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class AddJoke implements ICommandDefinition {
    public var paramsUsage = '(the joke)';
    public var description = L.a.n.g('model.commandlist.addjoke.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;
        var joke = new Joke();

        joke.content = args.join(' ');
        joke.save(function (err) {
            if (err != null) {
                Logger.exception(err);
                client.sendMessage(msg.channel, L.a.n.g('model.commandlist.addjoke.fail', cast [msg.author]));
            } else {
                client.sendMessage(msg.channel, L.a.n.g('model.commandlist.addjoke.success', cast [msg.author]));
            }
        });
    }
}
