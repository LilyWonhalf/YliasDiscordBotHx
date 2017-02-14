package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import discordbothx.log.Logger;
import yliasdiscordbothx.model.entity.Joke;

class DeleteJoke extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(the joke ID)';
        nbRequiredParams = 1;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;

        if (args.length > 0) {
            var joke: Joke = new Joke();
            var primaryValues = new Map<String, String>();

            primaryValues.set('id', cast Std.parseInt(args[0]));

            joke.retrieve(primaryValues, function(found: Bool) {
                if (!found) {
                    context.sendToChannel(l('not_found', cast [author]));
                } else {
                    joke.remove(function (err: Dynamic) {
                        if (err != null) {
                            Logger.exception(err);
                            context.sendToChannel(l('failed', cast [author]));
                        } else {
                            context.sendToChannel(l('success', cast [author]));
                        }
                    });
                }
            });
        } else {
            context.sendToChannel(l('wong_format', cast [author]));
        }
    }

    override public function checkFormat(args: Array<String>): Bool {
        return args.length == 1 && !Math.isNaN(cast args.join(' '));
    }
}
