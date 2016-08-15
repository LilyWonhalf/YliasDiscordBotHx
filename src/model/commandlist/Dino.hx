package model.commandlist;

import utils.ArrayUtils;
import haxe.Json;
import utils.DiscordUtils;
import nodejs.http.HTTP.HTTPMethod;
import utils.Logger;
import utils.HttpUtils;
import translations.LangCenter;

class Dino implements ICommandDefinition {
    public var paramsUsage = '';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.dino.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        HttpUtils.query(false, 'dinosaurpictures.org', '/api/dinosaur/random', cast HTTPMethod.Get, function (data: String) {
            var response: Dynamic = null;

            try {
                response = Json.parse(data);
            } catch (err: Dynamic) {
                Logger.exception(err);
            }

            if (response != null && Reflect.hasField(response, 'pics')) {
                var pics:Array<Dynamic> = response.pics;
                var pic = ArrayUtils.random(pics);

                _context.rawSendToChannel(author + ' => ' + pic.url);
            } else {
                Logger.error('Failed to load a dino picture');
                _context.sendToChannel('model.commandlist.dino.process.fail', cast [author]);
            }
        });
    }
}
