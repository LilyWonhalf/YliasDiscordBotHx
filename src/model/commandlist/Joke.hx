package model.commandlist;

import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;
import model.entity.Joke as JokeEntity;

class Joke implements ICommandDefinition {
    public var paramsUsage = '*(search word 1)* *(search word 2)* *(search word n)*';
    public var description = L.a.n.g('model.commandlist.joke.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;

        if (args.length == 1 && !Math.isNaN(cast args[0])) {
            var joke = new JokeEntity();
            var primaryValues = new Map<String, String>();

            primaryValues.set('id', cast Std.parseInt(args[0]));

            joke.retrieve(primaryValues, function (found) {
                if (found) {
                    client.sendMessage(msg.channel, L.a.n.g('model.commandlist.joke.process.answer', cast [cast msg.author, cast joke.id, joke.content]));
                } else {
                    JokeEntity.getRandom(args, function (joke: JokeEntity) {
                        if (joke != null) {
                            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.joke.process.answer', cast [cast msg.author, cast joke.id, joke.content]));
                        } else {
                            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.joke.process.not_found', cast [msg.author]));
                        }
                    });
                }
            });
        } else {
            JokeEntity.getRandom(args, function (joke: JokeEntity) {
                if (joke != null) {
                    client.sendMessage(msg.channel, L.a.n.g('model.commandlist.joke.process.answer', cast [cast msg.author, cast joke.id, joke.content]));
                } else {
                    client.sendMessage(msg.channel, L.a.n.g('model.commandlist.joke.process.not_found', cast [msg.author]));
                }
            });
        }
    }
}
