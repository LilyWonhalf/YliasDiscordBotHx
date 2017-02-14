package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.utils.DiscordUtils;
import yliasdiscordbothx.model.entity.TagBlacklist;

class DeleteTagFromBlacklist extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(tag) *(server ID)*';
        nbRequiredParams = 1;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;

        if (args.length > 0) {
            var tag: String = StringTools.trim(args[0]);
            var idServer: String = DiscordUtils.getServerIdFromMessage(context.message);
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
                            context.sendToChannel(l('fail', cast [author, err]));
                        } else {
                            context.sendToChannel(l('success', cast [author]));
                        }
                    });
                } else {
                    context.sendToChannel(l('not_found', cast [author]));
                }
            });
        } else {
            context.sendToChannel(l('wrong_format', cast [author]));
        }
    }
}
