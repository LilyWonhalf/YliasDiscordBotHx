package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import discordbothx.log.Logger;
import yliasdiscordbothx.model.entity.Joke;

class AddJoke extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(the joke)';
        nbRequiredParams = 1;
    }

    override public function process(args: Array<String>): Void {
        var joke = new Joke();
        var author = context.message.author;

        joke.content = args.join(' ');
        joke.save(function (err) {
            if (err != null) {
                Logger.exception(err);
                context.sendToChannel(l('fail', cast [author]));
            } else {
                context.sendToChannel(l('success', cast [author]));
            }
        });
    }
}
