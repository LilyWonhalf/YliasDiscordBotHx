package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.model.entity.WelcomeMessage;
import yliasdiscordbothx.utils.YliasDiscordUtils;
import StringTools;

class SetWelcomeMessage extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(message)';
        nbRequiredParams = 1;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;

        if (args.length > 0) {
            var message: String = StringTools.trim(args.join(' '));
            var idServer: String = YliasDiscordUtils.getServerIdFromMessage(context.message);
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
                        context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                            'Set welcome message',
                            l('fail', cast [author, err]),
                            Emotion.SAD
                        ));
                    } else {
                        context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                            'Set welcome message',
                            l('success', cast [author]),
                            Emotion.NEUTRAL
                        ));
                    }
                });
            });
        }
    }
}
