package yliasdiscordbothx.model.commandlist;

import yliasdiscordbothx.utils.YliasDiscordUtils;
import discordbothx.core.CommunicationContext;
import nodejs.http.HTTP.HTTPMethod;
import yliasdiscordbothx.utils.HttpQuery;
import haxe.Json;

class Describe extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(picture URL)';
        nbRequiredParams = 1;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var domain = 'captionbot.azurewebsites.net';
        var path = '/api';
        var query: HttpQuery = new HttpQuery(domain, path + '/messages?language=en-US');

        query.method = cast HTTPMethod.Post;
        query.data = Json.stringify(
            {
                Content: args.join(' '),
                Type: 'CaptionRequest'
            }
        );

        YliasDiscordUtils.setTyping(true, context.message.channel);

        query.send().then(function (data: String) {
            YliasDiscordUtils.setTyping(false, context.message.channel);
            var response = Json.parse(data);

            context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                'Describe',
                YliasDiscordUtils.getCleanString(context, response),
                Emotion.NEUTRAL
            ), cast author);
        });
    }
}
