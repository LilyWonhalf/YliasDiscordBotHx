package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.model.entity.Joke as JokeEntity;

class Joke extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '*(search word 1)* *(search word 2)* *(search word n)*';
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;

        if (args.length == 1 && !Math.isNaN(cast args[0])) {
            var joke = new JokeEntity();
            var primaryValues = new Map<String, String>();

            primaryValues.set('id', cast Std.parseInt(args[0]));

            joke.retrieve(primaryValues, function (found) {
                if (found) {
                    context.sendToChannel(l('answer', cast [cast author, cast joke.id, joke.content]));
                } else {
                    JokeEntity.getRandom(args, function (joke: JokeEntity) {
                        if (joke != null) {
                            context.sendToChannel(l('answer', cast [cast author, cast joke.id, joke.content]));
                        } else {
                            context.sendToChannel(l('not_found', cast [author]));
                        }
                    });
                }
            });
        } else {
            JokeEntity.getRandom(args, function (joke: JokeEntity) {
                if (joke != null) {
                    context.sendToChannel(l('answer', cast [cast author, cast joke.id, joke.content]));
                } else {
                    context.sendToChannel(l('not_found', cast [author]));
                }
            });
        }
    }
}
