package model.commandlist;

import utils.Logger;
import model.entity.Joke;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class DeleteJoke implements ICommandDefinition {
    public var paramsUsage = '(the joke ID)';
    public var description = L.a.n.g('model.commandlist.deletejoke.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;

        if (args.length > 0 && Std.is(args[0], Int)) {
            var joke: Joke = new Joke();
            var primaryValues = new Map<String, String>();

            primaryValues.set('id', cast Std.parseInt(args[0]));

            joke.retrieve(primaryValues, function(found: Bool) {
                if (!found) {
                    client.sendMessage(msg.channel, L.a.n.g('model.commandlist.deletejoke.process.not_found', cast [msg.author]));
                } else {
                    joke.remove(function (err: Dynamic) {
                        if (err != null) {
                            Logger.exception(err);
                            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.deletejoke.process.failed', cast [msg.author]));
                        } else {
                            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.deletejoke.process.success', cast [msg.author]));
                        }
                    });
                }
            });
        } else {
            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.deletejoke.process.wong_format', cast [msg.author]));
        }
    }
}
