package model.commandlist;

import utils.DiscordUtils;
import model.entity.TagBlacklist;
import StringTools;
import translations.LangCenter;

class AddTagToBlacklist implements ICommandDefinition {
    public var paramsUsage = '(tag)';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.addtagtoblacklist.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        if (args.length > 0) {
            var tag: String = StringTools.trim(args.join(' '));
            var idServer: String = DiscordUtils.getServerIdFromMessage(_context.getMessage());

            var newTag: TagBlacklist = new TagBlacklist();

            newTag.idServer = idServer;
            newTag.tag = tag;

            newTag.save(function (err: Dynamic) {
                if (err != null) {
                    _context.sendToChannel('model.commandlist.addtagtoblacklist.fail', cast [author, err]);
                } else {
                    _context.sendToChannel('model.commandlist.addtagtoblacklist.success', cast [author]);
                }
            });
        } else {
            _context.sendToChannel('model.commandlist.addtagtoblacklist.wrong_format', cast [author]);
        }
    }
}
