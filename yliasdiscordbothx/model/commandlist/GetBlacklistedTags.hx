package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import discordbothx.log.Logger;
import yliasdiscordbothx.model.entity.TagBlacklist;
import yliasdiscordbothx.utils.DiscordUtils;

class GetBlacklistedTags extends YliasBaseCommand {
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

        TagBlacklist.getAllForServer(serverId, function(err: Dynamic, tags: Array<String>) {
            if (err != null) {
                Logger.exception(err);
                context.sendToChannel(l('fail', cast [cast author]));
            } else {
                context.sendToChannel(l('success', cast [cast author, tags.join('\n')]));
            }
        });
    }
}
