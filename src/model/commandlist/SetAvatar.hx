package model.commandlist;

import utils.Logger;
import nodejs.Buffer;
import nodejs.NodeJS;
import utils.DiscordUtils;
import translations.LangCenter;

class SetAvatar implements ICommandDefinition {
    public var paramsUsage = '';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.setavatar.description');
    }

    public function process(args: Array<String>): Void {
        var request = NodeJS.require('request');

        request(
            {
                url: args.join(' '),
                encoding: 'binary'
            },
            function (err: Dynamic, response: Dynamic, body: String) {
                if (err == null && response.statusCode == 200 && body.length > 0) {
                    Core.instance.setClientAvatar(new Buffer(body, 'binary'), function (err: Dynamic) {
                        if (err == null) {
                            _context.sendToChannel('model.commandlist.setavatar.process.answer', cast [_context.getMessage().author]);
                        } else {
                            Logger.exception(err);
                            _context.sendToChannel('model.commandlist.setavatar.process.fail', cast [_context.getMessage().author]);
                        }
                    });
                } else {
                    Logger.exception(err);
                    _context.sendToChannel('model.commandlist.setavatar.process.network_error', cast [_context.getMessage().author]);
                }
            }
        );
    }
}
