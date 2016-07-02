package model.commandlist;

import model.entity.WelcomeMessage;
import utils.DiscordUtils;
import StringTools;
import translations.LangCenter;

class SetWelcomeMessage implements ICommandDefinition {
    public var paramsUsage = '(message)';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.setwelcomemessage.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        if (args.length > 0) {
            var message: String = StringTools.trim(args.join(' '));
            var idServer: String = DiscordUtils.getServerIdFromMessage(_context.getMessage());
            var welcomeMessage: WelcomeMessage = new WelcomeMessage();
            var uniqueValues: Map<String, String> = new Map<String, String>();

            uniqueValues.set('idServer', idServer);

            welcomeMessage.retrieve(uniqueValues, function (found: Bool): Void {
                if (!found) {
                    welcomeMessage.idServer = idServer;
                }

                welcomeMessage.message = message;

                welcomeMessage.save(function (err: Dynamic) {
                    if (err != null) {
                        _context.sendToChannel('model.commandlist.setwelcomemessage.process.fail', cast [author, err]);
                    } else {
                        _context.sendToChannel('model.commandlist.setwelcomemessage.process.success', cast [author]);
                    }
                });
            });
        } else {
            _context.sendToChannel('model.commandlist.setwelcomemessage.process.wrong_format', cast [author]);
        }
    }
}
