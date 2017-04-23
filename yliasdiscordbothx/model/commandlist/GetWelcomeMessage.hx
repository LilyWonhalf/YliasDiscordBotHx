package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.model.entity.WelcomeMessage;
import discordbothx.log.Logger;
import yliasdiscordbothx.utils.YliasDiscordUtils;

class GetWelcomeMessage extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '*(server id)*';
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var serverId: String = YliasDiscordUtils.getServerIdFromMessage(context.message);

        if (args.length > 0 && StringTools.trim(args[0]).length > 0) {
            serverId = StringTools.trim(args[0]);
        }

        WelcomeMessage.getForServer(serverId, function(err: Dynamic, message: String) {
            if (err != null) {
                Logger.exception(err);
                context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                    'Get welcome message',
                    YliasDiscordUtils.getCleanString(context, l('fail', cast [author, err])),
                    Emotion.SAD
                ));
            } else {
                if (message != null) {
                    context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                        'Get welcome message',
                        YliasDiscordUtils.getCleanString(context, l('success', cast [cast author, message])),
                        Emotion.NEUTRAL
                    ));
                } else {
                    context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                        'Get welcome message',
                        YliasDiscordUtils.getCleanString(context, l('not_found', cast [author])),
                        Emotion.NEUTRAL
                    ));
                }
            }
        });
    }
}
