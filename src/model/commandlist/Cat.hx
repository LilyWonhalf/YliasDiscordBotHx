package model.commandlist;

import utils.DiscordUtils;
import nodejs.http.HTTP.HTTPMethod;
import utils.Logger;
import haxe.Json;
import utils.HttpUtils;
import translations.LangCenter;

class Cat implements ICommandDefinition {
    public var paramsUsage = '';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.cat.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        HttpUtils.query(false, 'random.cat', '/meow', cast HTTPMethod.Get, function (data: String) {
            var response: Dynamic = null;

            try {
                response = Json.parse(data);
            } catch (err: Dynamic) {
                Logger.exception(err);
            }

            if (response != null && Reflect.hasField(response, 'file')) {
                _context.rawSendToChannel(author + ' => ' + response.file);
            } else {
                Logger.error('Failed to load a cat picture');
                _context.sendToChannel('model.commandlist.cat.process.fail', cast [author]);
            }
        });
    }
}
