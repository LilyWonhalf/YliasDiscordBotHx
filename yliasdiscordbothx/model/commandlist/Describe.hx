package yliasdiscordbothx.model.commandlist;

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

        if (args.length > 0) {
            var domain = 'www.captionbot.ai';
            var path = '/api';
            var query: HttpQuery = new HttpQuery(domain, path + '/init');

            context.sendToChannel(l('wait', cast [author]));

            query.send().then(function (data: String) {
                var session: String = Json.parse(data);

                query.path = path + '/message';
                query.method = cast HTTPMethod.Post;
                query.data = Json.stringify(
                    {
                        conversationId: session,
                        waterMark: '',
                        userMessage: args.join(' ')
                    }
                );

                query.send().then(function (data: String) {
                    query.path = path + '/message?waterMark=&conversationId=' + session;
                    query.method = cast HTTPMethod.Get;
                    query.data = null;

                    query.send().then(function (data: String) {
                        var response = Json.parse(Json.parse(data));

                        context.sendToChannel(author + ', ' + response.BotMessages[1]);
                    });
                });
            });
        } else {
            context.sendToChannel(l('error'));
        }
    }
}
