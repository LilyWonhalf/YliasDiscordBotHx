package model.commandlist;

import utils.DiscordUtils;
import model.entity.WelcomeMessage;
import translations.LangCenter;

class DeleteWelcomeMessage implements ICommandDefinition {
    public var paramsUsage = '*(server ID)*';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.deletewelcomemessage.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;
        var idServer: String = DiscordUtils.getServerIdFromMessage(_context.getMessage());
        var welcomeMessageToDelete: WelcomeMessage = new WelcomeMessage();
        var primaryValues = new Map<String, String>();

        if (args.length > 0 && StringTools.trim(args[0]).length > 0) {
            idServer = StringTools.trim(args[0]);
        }

        primaryValues.set('idServer', idServer);

        welcomeMessageToDelete.retrieve(primaryValues, function (found: Bool) {
            if (found) {
                welcomeMessageToDelete.remove(function (err: Dynamic) {
                    if (err != null) {
                        _context.sendToChannel('model.commandlist.deletewelcomemessage.process.fail', cast [author, err]);
                    } else {
                        _context.sendToChannel('model.commandlist.deletewelcomemessage.process.success', cast [author]);
                    }
                });
            } else {
                _context.sendToChannel('model.commandlist.deletewelcomemessage.process.not_found', cast [author]);
            }
        });
    }
}
