package yliasdiscordbothx.model.commandlist;

import yliasdiscordbothx.utils.YliasDiscordUtils;
import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.Bot;
import discordhx.message.Message;
import yliasdiscordbothx.utils.ArrayUtils;
import haxe.Json;
import discordbothx.log.Logger;
import yliasdiscordbothx.utils.HttpQuery;

class Imgur extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '*(search)*';
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var bestArray: Array<String> = new Array<String>();
        var domain = 'api.imgur.com';
        var path = '/3/gallery/search/';
        var headers = new Map<String, String>();
        var search: String = StringTools.trim(args.join(' '));
        var query: HttpQuery = new HttpQuery(domain);

        if (search == null || search.length < 1) {
            path = '/3/gallery/random/random/';
        }

        path += '?q_size_px=med&q=' + StringTools.urlEncode(search);

        headers.set('Authorization', 'Client-ID ' + Bot.instance.authDetails.IMGUR_CLIENT_ID);

        query.path = path;
        query.headers = headers;

        YliasDiscordUtils.setTyping(true, context.message.channel);

        query.send().then(function (data: String) {
            var response: Dynamic = null;

            try {
                response = Json.parse(data);
            } catch (err: Dynamic) {
                Logger.exception(err);
            }

            if (response != null && Reflect.hasField(response, 'data')) {
                if (response.data.length > 0) {
                    var results: Array<Dynamic> = cast response.data;

                    results = results.filter(function (result: Dynamic): Bool {
                        return Reflect.hasField(result, 'type') && Reflect.field(result, 'type').indexOf('image') > -1 && Reflect.field(result, 'nsfw') == false;
                    });

                    var result: Dynamic = ArrayUtils.random(results);

                    query.path = '/3/gallery/image/' + result.id;

                    query.send().then(function (data: String): Void {
                        var response: Dynamic = null;

                        try {
                            response = Json.parse(data);
                        } catch (err: Dynamic) {
                            Logger.exception(err);
                        }

                        if (response != null && Reflect.hasField(response, 'data')) {
                            var link: String = response.data.link;

                            YliasDiscordUtils.setTyping(false, context.message.channel);
                            context.sendFileToChannel(link, link.substring(link.lastIndexOf('/') + 1));
                        } else {
                            Logger.error('Failed to load Imgur image (step 2)');
                            Logger.debug(response);

                            YliasDiscordUtils.setTyping(false, context.message.channel);
                            context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                                'Imgur',
                                l('fail', cast [author]),
                                Emotion.SAD
                            ));
                        }
                    });
                } else {
                    YliasDiscordUtils.setTyping(false, context.message.channel);
                    context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                        'Imgur',
                        l('not_found', cast [author]),
                        Emotion.SAD
                    ));
                }
            } else {
                Logger.error('Failed to load Imgur image (step 1)');
                Logger.debug(response);

                YliasDiscordUtils.setTyping(false, context.message.channel);
                context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                    'Imgur',
                    l('fail', cast [author]),
                    Emotion.SAD
                ));
            }
        });
    }
}
