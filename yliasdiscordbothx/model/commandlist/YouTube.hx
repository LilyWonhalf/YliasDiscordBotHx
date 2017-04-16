package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.Bot;
import yliasdiscordbothx.utils.YliasDiscordUtils;
import discordbothx.log.Logger;
import haxe.Json;
import yliasdiscordbothx.utils.HttpQuery;
import discordhx.message.Message;

class YouTube extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(search)';
        nbRequiredParams = 1;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var videoUrl = 'https://www.youtube.com/watch?v=';
        var host = 'www.googleapis.com';
        var path = '/youtube/v3/search?part=snippet&maxResults=50';
        var query: HttpQuery = new HttpQuery(host);

        path += '&q=' + StringTools.urlEncode(args.join(' '));
        path += '&key=' + Bot.instance.authDetails.GOOGLE_API_KEY;

        query.path = path;

        YliasDiscordUtils.setTyping(true, context.message.channel);

        query.send().then(function (data: String) {
            var parsedData: Dynamic;

            try {
                parsedData = Json.parse(data);
            } catch (e: Dynamic) {
                Logger.exception(e);
                parsedData = null;
            }

            if (parsedData != null) {
                if (!Reflect.hasField(parsedData, 'error')) {
                    if (Reflect.hasField(parsedData, 'items') && cast(Reflect.field(parsedData, 'items'), Array<Dynamic>).length > 0) {
                        var items: Array<Dynamic> = cast Reflect.field(parsedData, 'items');
                        var link: String = null;

                        for (item in items) {
                            if (item.id.kind == 'youtube#video') {
                                link = videoUrl + item.id.videoId;
                                break;
                            }
                        }

                        if (link != null) {
                            YliasDiscordUtils.setTyping(false, context.message.channel);
                            context.sendToChannel(link);
                        } else {
                            Logger.error('Failed to load a youtube video (step 4)');

                            YliasDiscordUtils.setTyping(false, context.message.channel);
                            context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                                'YouTube',
                                l('not_found', cast [author]),
                                Emotion.SAD
                            ));
                        }
                    } else {
                        Logger.error('Failed to load a youtube video (step 3)');

                        YliasDiscordUtils.setTyping(false, context.message.channel);
                        context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                            'YouTube',
                            l('not_found', cast [author]),
                            Emotion.SAD
                        ));
                    }
                } else {
                    Logger.error('Failed to load a youtube video (step 2)');
                    Logger.exception(Reflect.field(parsedData, 'error'));

                    YliasDiscordUtils.setTyping(false, context.message.channel);
                    context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                        'YouTube',
                        l('error', cast [author]),
                        Emotion.SAD
                    ));
                }
            } else {
                Logger.error('Failed to load a youtube video (step 1)');

                YliasDiscordUtils.setTyping(false, context.message.channel);
                context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                    'YouTube',
                    l('failed', cast [author]),
                    Emotion.SAD
                ));
            }
        });
    }
}
