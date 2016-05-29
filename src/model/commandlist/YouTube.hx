package model.commandlist;

import translations.LangCenter;
import utils.DiscordUtils;
import utils.Humanify;
import utils.Logger;
import haxe.Json;
import nodejs.http.HTTP.HTTPMethod;
import utils.HttpUtils;
import config.AuthDetails;
import translations.LangCenter;
import external.discord.message.Message;

class YouTube implements ICommandDefinition {
    public var paramsUsage = '';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.youtube.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;
        var videoUrl = 'https://www.youtube.com/watch?v=';
        var host = 'www.googleapis.com';
        var path = '/youtube/v3/search?part=snippet&maxResults=50';

        path += '&q=' + StringTools.urlEncode(args.join(' '));
        path += '&key=' + AuthDetails.GOOGLE_API_KEY;

        _context.sendToChannel('model.commandlist.youtube.process.wait', cast [author]);

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
                            var idServer = DiscordUtils.getServerIdFromMessage(_context.getMessage());
                            var message = LangCenter.instance.translate(idServer, Humanify.getMultimediaContentDeliverySentence()) + '\n' + link;
                            _context.rawSendToChannel(message);
                        } else {
                            Logger.error('Failed to load a youtube video (step 4)');
                            _context.sendToChannel('model.commandlist.youtube.process.not_found', cast [author]);
                        }
                    } else {
                        Logger.error('Failed to load a youtube video (step 3)');
                        _context.sendToChannel('model.commandlist.youtube.process.not_found', cast [author]);
                    }
                } else {
                    Logger.error('Failed to load a youtube video (step 2)');
                    Logger.exception(Reflect.field(parsedData, 'error'));
                    _context.sendToChannel('model.commandlist.youtube.process.error', cast [author]);
                }
            } else {
                Logger.error('Failed to load a youtube video (step 1)');
                _context.sendToChannel('model.commandlist.youtube.process.fail', cast [author]);
            }
        });
    }
}
