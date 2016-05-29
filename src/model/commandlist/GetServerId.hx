package model.commandlist;

import utils.DiscordUtils;
import external.discord.channel.TextChannel;
import translations.LangCenter;

class GetServerId implements ICommandDefinition {
    public var paramsUsage = '';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.getserverid.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        if (_context.getMessage().channel.isPrivate) {
            _context.sendToChannel('model.commandlist.getserverod.process.private_conversation', cast [author]);
        } else {
            var channel: TextChannel = cast _context.getMessage().channel;

            _context.sendToChannel('model.commandlist.getserverod.process.answer', cast [cast author, channel.server.id]);
        }
    }
}
