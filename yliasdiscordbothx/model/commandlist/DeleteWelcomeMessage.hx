package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.utils.DiscordUtils;
import yliasdiscordbothx.model.entity.WelcomeMessage;

class DeleteWelcomeMessage extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '*(server ID)*';
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var idServer: String = DiscordUtils.getServerIdFromMessage(context.message);
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
                        context.sendToChannel(l('fail', cast [author, err]));
                    } else {
                        context.sendToChannel(l('success', cast [author]));
                    }
                });
            } else {
                context.sendToChannel(l('not_found', cast [author]));
            }
        });
    }
}
