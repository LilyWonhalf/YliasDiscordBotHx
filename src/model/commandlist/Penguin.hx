package model.commandlist;

import haxe.Json;
import utils.DiscordUtils;
import nodejs.http.HTTP.HTTPMethod;
import utils.Logger;
import utils.HttpUtils;
import translations.LangCenter;

class Penguin implements ICommandDefinition {
    public var paramsUsage = '';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.penguin.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        HttpUtils.query(false, 'penguin.wtf', '', cast HTTPMethod.Get, function (data: String) {
            if (data != null && data.split('\n').length < 2) {
                _context.rawSendToChannel(author + ' => ' + data);
            } else {
                Logger.error('Failed to load a penguin picture');
                _context.sendToChannel('model.commandlist.penguin.process.fail', cast [author]);
            }
        });
    }
}
