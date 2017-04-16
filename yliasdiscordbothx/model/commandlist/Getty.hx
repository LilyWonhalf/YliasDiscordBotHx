package yliasdiscordbothx.model.commandlist;

import yliasdiscordbothx.utils.YliasDiscordUtils;
import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.Bot;
import discordhx.message.Message;
import yliasdiscordbothx.utils.ArrayUtils;
import haxe.Json;
import nodejs.http.HTTP.HTTPMethod;
import discordbothx.log.Logger;
import yliasdiscordbothx.utils.HttpQuery;

class Getty extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '*(search)*';
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var bestArray: Array<String> = new Array<String>();
        var domain = 'api.gettyimages.com';
        var path = '/v3/search/images';
        var headers = new Map<String, String>();
        var search: String = StringTools.trim(args.join(' '));
        var query: HttpQuery = new HttpQuery(domain);

        if (search == 'awoo') {
            search = 'wolf howl';
        }

        if (search == 'snek') {
            search = 'snake';
        }

        if (search == 'snep') {
            search = 'snow leopard';
        }

        if (['birb', 'burb', 'burd'].indexOf(search) > -1) {
            search = 'bird';
        }

        if (search == null || search.length < 1) {
            search = 'animal';
        }

        path += '?embed_content_only=true';
        path += '&exclude_nudity=true';
        path += '&fields=display_set';
        path += '&file_types=jpg';
        path += '&number_of_people=none';
        path += '&phrase=' + StringTools.urlEncode(search);
        path += '&sort_order=best_match';

        headers.set('Api-Key', Bot.instance.authDetails.GETTY_KEY);

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

            if (response != null && Reflect.hasField(response, 'result_count') && Reflect.hasField(response, 'images')) {
                if (response.result_count > 0) {
                    var nbResults: Int = response.result_count;
                    var nbPerPage: Int = response.images.length;
                    var nbPages: Int = cast Math.min(Math.ceil(nbResults / nbPerPage), 6); // Limit at 6 pages so we don't end up with unrelevant content

                    query.path = path + '&page=' + Math.ceil(Math.random() * nbPages + 0.1);

                    query.send().then(function (data: String) {
                        var response: Dynamic = null;

                        try {
                            response = Json.parse(data);
                        } catch (err: Dynamic) {
                            Logger.exception(err);
                        }

                        if (response != null && Reflect.hasField(response, 'result_count') && Reflect.hasField(response, 'images')) {
                            var image: Dynamic = ArrayUtils.random(cast response.images);
                            var displaySizes: Array<Dynamic> = image.display_sizes;
                            var uri: String = displaySizes[0].uri;
                            var hash: Int = 0;

                            for (i in 0...uri.length) {
                                hash  = ((hash << 5) - hash) + uri.charCodeAt(i);
                                hash |= 0;
                            }

                            YliasDiscordUtils.setTyping(false, context.message.channel);
                            context.sendFileToChannel(displaySizes[0].uri, hash + '.png', author.toString()).catchError(function (error: Dynamic) {
                                Logger.error('Failed to load Getty image (step 3)');
                                Logger.debug(response);

                                context.sendToChannel(l('fail', cast [author]));
                            });
                        } else {
                            Logger.error('Failed to load Getty image (step 2)');
                            Logger.debug(response);

                            YliasDiscordUtils.setTyping(false, context.message.channel);
                            context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                                'Getty',
                                l('fail', cast [author]),
                                Emotion.SAD
                            ));
                        }
                    });
                } else {
                    YliasDiscordUtils.setTyping(false, context.message.channel);
                    context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                        'Getty',
                        l('not_found', cast [author]),
                        Emotion.SAD
                    ));
                }
            } else {
                Logger.error('Failed to load Getty image (step 1)');
                Logger.debug(response);

                YliasDiscordUtils.setTyping(false, context.message.channel);
                context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                    'Getty',
                    l('fail', cast [author]),
                    Emotion.SAD
                ));
            }
        });
    }
}
