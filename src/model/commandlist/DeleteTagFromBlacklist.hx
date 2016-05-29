package model.commandlist;

import utils.DiscordUtils;
import model.entity.TagBlacklist;
import translations.LangCenter;

class DeleteTagFromBlacklist implements ICommandDefinition {
    public var paramsUsage = '(tag) *(server ID)*';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.deletetagfromblacklist.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        if (args.length > 0) {
            var tag: String = StringTools.trim(args[0]);
            var idServer: String = DiscordUtils.getServerIdFromMessage(_context.getMessage());
            var tagToDelete: TagBlacklist = new TagBlacklist();
            var primaryValues = new Map<String, String>();

            if (args.length > 1 && StringTools.trim(args[1]).length > 0) {
                idServer = StringTools.trim(args[1]);
            }

            primaryValues.set('idServer', idServer);
            primaryValues.set('tag', tag);

            tagToDelete.retrieve(primaryValues, function (found: Bool) {
                if (found) {
                    tagToDelete.remove(function (err: Dynamic) {
                        if (err != null) {
                            _context.sendToChannel('model.commandlist.deletetagfromblacklist.fail', cast [author, err]);
                        } else {
                            _context.sendToChannel('model.commandlist.deletetagfromblacklist.success', cast [author]);
                        }
                    });
                } else {
                    _context.sendToChannel('model.commandlist.deletetagfromblacklist.not_found', cast [author]);
                }
            });
        } else {
            _context.sendToChannel('model.commandlist.deletetagfromblacklist.wrong_format', cast [author]);
        }
    }
}
