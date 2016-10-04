package model.commandlist;

import utils.DiscordUtils;
import nodejs.http.HTTP.HTTPMethod;
import utils.HttpUtils;
import translations.LangCenter;
import haxe.Json;

class Describe implements ICommandDefinition {
    public var paramsUsage = '(picture URL)';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.describe.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        if (args.length > 0) {
            var domain = 'www.captionbot.ai';
            var path = '/api';

            _context.sendToChannel('model.commandlist.describe.process.wait', cast [author]);

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

                            _context.rawSendToChannel(author + ' => ' + response.BotMessages[1]);
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
            _context.sendToChannel('model.commandlist.describe.process.error');
        }
    }
}
