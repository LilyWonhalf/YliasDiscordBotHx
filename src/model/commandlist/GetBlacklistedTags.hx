package model.commandlist;

import utils.Logger;
import model.entity.TagBlacklist;
import utils.DiscordUtils;
import translations.LangCenter;

class GetBlacklistedTags implements ICommandDefinition {
    public var paramsUsage = '*(server id)*';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.getblacklistedtags.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;
        var serverId: String = DiscordUtils.getServerIdFromMessage(_context.getMessage());

        if (args.length > 0 && StringTools.trim(args[0]).length > 0) {
            serverId = StringTools.trim(args[0]);
        }

        TagBlacklist.getAll(serverId, function(err: Dynamic, tags: Array<String>) {
            if (err != null) {
                Logger.exception(err);
                _context.sendToChannel('model.commandlist.getblacklistedtags.process.fail', cast [cast author]);
            } else {
                _context.sendToChannel('model.commandlist.getblacklistedtags.process.success', cast [cast author, tags.join('\n')]);
            }
        });
    }
}
