package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.utils.YliasDiscordUtils;
import yliasdiscordbothx.model.entity.WelcomeMessage;

class DeleteWelcomeMessage extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '*(server ID)*';
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var idServer: String = YliasDiscordUtils.getServerIdFromMessage(context.message);
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
                        context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                            'Delete welcome message',
                            YliasDiscordUtils.getCleanString(context, l('fail', cast [author, err])),
                            Emotion.SAD
                        ));
                    } else {
                        context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                            'Delete welcome message',
                            YliasDiscordUtils.getCleanString(context, l('success', cast [author])),
                            Emotion.WINK
                        ));
                    }
                });
            } else {
                context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                    'Delete welcome message',
                    YliasDiscordUtils.getCleanString(context, l('not_found', cast [author])),
                    Emotion.WINK
                ));
            }
        });
    }
}
