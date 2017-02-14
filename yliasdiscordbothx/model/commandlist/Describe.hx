package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import nodejs.http.HTTP.HTTPMethod;
import yliasdiscordbothx.utils.HttpUtils;
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

            context.sendToChannel(l('wait', cast [author]));

            HttpUtils.query(true, domain, path + '/init', cast HTTPMethod.Get, function (data: String) {
                var session: String = Json.parse(data);

                HttpUtils.query(
                    true,
                    domain,
                    path + '/message',
                    cast HTTPMethod.Post,
                    function (data: String) {
                        HttpUtils.query(true, domain, path + '/message?waterMark=&conversationId=' + session, cast HTTPMethod.Get, function (data: String) {
                            var response = Json.parse(Json.parse(data));

                            context.sendToChannel(author + ', ' + response.BotMessages[1]);
                        });
                    },
                    Json.stringify(
                        {
                            conversationId: session,
                            waterMark: '',
                            userMessage: args.join(' ')
                        }
                    )
                );
            });
        } else {
            context.sendToChannel(l('error'));
        }
    }
}
