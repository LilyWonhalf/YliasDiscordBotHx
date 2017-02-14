package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.model.entity.WelcomeMessage;
import discordbothx.log.Logger;
import yliasdiscordbothx.utils.DiscordUtils;

class GetWelcomeMessage extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '*(server id)*';
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var serverId: String = DiscordUtils.getServerIdFromMessage(context.message);

        if (args.length > 0 && StringTools.trim(args[0]).length > 0) {
            serverId = StringTools.trim(args[0]);
        }

        WelcomeMessage.getForServer(serverId, function(err: Dynamic, message: String) {
            if (err != null) {
                Logger.exception(err);
                context.sendToChannel(l('fail', cast [author, err]));
            } else {
                if (message != null) {
                    context.sendToChannel(l('success', cast [cast author, message]));
                } else {
                    context.sendToChannel(l('not_found', cast [author]));
                }
            }
        });
    }
}
