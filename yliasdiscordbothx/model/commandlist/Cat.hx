package yliasdiscordbothx.model.commandlist;

import yliasdiscordbothx.utils.YliasDiscordUtils;
import discordbothx.core.CommunicationContext;
import discordbothx.log.Logger;
import haxe.Json;
import yliasdiscordbothx.utils.HttpQuery;

class Cat extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var query: HttpQuery = new HttpQuery('aws.random.cat', '/meow');

        query.secured = false;

        query.send().then(function (data: String) {
            var response: Dynamic = null;

            try {
                response = Json.parse(data);
            } catch (err: Dynamic) {
                Logger.exception(err);
                Logger.debug(data);
            }

            if (response != null && Reflect.hasField(response, 'file')) {
                context.sendFileToChannel(response.file, 'cat.jpg', author.toString());
            } else {
                Logger.debug(data);
                context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                    'Meow!',
                    YliasDiscordUtils.getCleanString(context, l('fail', cast [author])),
                    Emotion.SAD
                ));
            }
        });
    }
}
