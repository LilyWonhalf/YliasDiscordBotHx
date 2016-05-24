package model.commandlist;

import utils.Humanify;
import utils.ArrayUtils;
import utils.Logger;
import haxe.Json;
import nodejs.http.HTTP.HTTPMethod;
import utils.HttpUtils;
import config.AuthDetails;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class YouTube implements ICommandDefinition {
    public var paramsUsage = '';
    public var description = L.a.n.g('model.commandlist.youtube.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;
        var videoUrl = 'https://www.youtube.com/watch?v=';
        var host = 'www.googleapis.com';
        var path = '/youtube/v3/search?part=snippet&maxResults=50';

        path += '&q=' + StringTools.urlEncode(args.join(' '));
        path += '&key=' + AuthDetails.GOOGLE_API_KEY;

        client.sendMessage(msg.channel, L.a.n.g('model.commandlist.youtube.process.wait', cast [msg.author]), cast {tts: false}, function (err: Dynamic, sentMsg: Message) {
            HttpUtils.query(true, host, path, cast HTTPMethod.Get, function (data: String) {
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
                                var message = Humanify.getMultimediaContentDeliverySentence() + '\n' + link;
                                client.sendMessage(msg.channel, message);
                            } else {
                                Logger.error('Failed to load a youtube video (step 4)');
                                client.sendMessage(msg.channel, L.a.n.g('model.commandlist.youtube.process.not_found', cast [msg.author]));
                            }
                        } else {
                            Logger.error('Failed to load a youtube video (step 3)');
                            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.youtube.process.not_found', cast [msg.author]));
                        }
                    } else {
                        Logger.error('Failed to load a youtube video (step 2)');
                        Logger.exception(Reflect.field(parsedData, 'error'));
                        client.sendMessage(msg.channel, L.a.n.g('model.commandlist.youtube.process.error', cast [msg.author]));
                    }
                } else {
                    Logger.error('Failed to load a youtube video (step 1)');
                    client.sendMessage(msg.channel, L.a.n.g('model.commandlist.youtube.process.fail', cast [msg.author]));
                }
            });
        });
    }
}
