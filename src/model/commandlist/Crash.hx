package model.commandlist;

import utils.DiscordUtils;
import translations.LangCenter;

class Crash implements ICommandDefinition {
    public var paramsUsage = '';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.crash.description');
    }

    public function process(args: Array<String>): Void {
        _context.sendToChannel('model.commandlist.crash.process.speech');
        untyped __js__('setTimeout(() => crash++, 1000)');
    }
}
