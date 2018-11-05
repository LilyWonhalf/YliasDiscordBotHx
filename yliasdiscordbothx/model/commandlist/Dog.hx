package yliasdiscordbothx.model.commandlist;

import yliasdiscordbothx.utils.YliasDiscordUtils;
import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.utils.HttpQuery;

class Dog extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var query: HttpQuery = new HttpQuery('random.dog', '/woof');

        query.send().then(function (data: String) {
            if (data != null && data.split('\n').length < 2) {
                context.sendFileToChannel('http://random.dog/' + data, data, author.toString());
            } else {
                context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                    'Dog',
                    YliasDiscordUtils.getCleanString(context, l('fail', cast [author])),
                    Emotion.SAD
                ));
            }
        });
    }
}
