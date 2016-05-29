package model.commandlist;

import utils.DiscordUtils;
import translations.LangCenter;

class Ping implements ICommandDefinition {
    public var paramsUsage = '';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.ping.description');
    }

    public function process(args: Array<String>): Void {
        _context.sendToChannel('model.commandlist.ping.process.answer', cast [_context.getMessage().author]);
    }
}
