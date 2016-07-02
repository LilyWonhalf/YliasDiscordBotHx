package model.commandlist;

import model.entity.WelcomeMessage;
import utils.Logger;
import utils.DiscordUtils;
import translations.LangCenter;

class GetWelcomeMessage implements ICommandDefinition {
    public var paramsUsage = '*(server id)*';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.getwelcomemessage.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;
        var serverId: String = DiscordUtils.getServerIdFromMessage(_context.getMessage());

        if (args.length > 0 && StringTools.trim(args[0]).length > 0) {
            serverId = StringTools.trim(args[0]);
        }

        WelcomeMessage.getForServer(serverId, function(err: Dynamic, message: String) {
            if (err != null) {
                Logger.exception(err);
                _context.sendToChannel('model.commandlist.getwelcomemessage.process.fail', cast [author, err]);
            } else {
                if (message != null) {
                    _context.sendToChannel('model.commandlist.getwelcomemessage.process.success', cast [cast author, message]);
                } else {
                    _context.sendToChannel('model.commandlist.getwelcomemessage.process.not_found', cast [author]);
                }
            }
        });
    }
}
