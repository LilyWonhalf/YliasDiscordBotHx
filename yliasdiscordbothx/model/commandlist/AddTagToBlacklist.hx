package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.utils.DiscordUtils;
import yliasdiscordbothx.model.entity.TagBlacklist;
import StringTools;

class AddTagToBlacklist extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(tag)';
        nbRequiredParams = 1;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;

        if (args.length > 0) {
            var tag: String = StringTools.trim(args.join(' '));
            var idServer: String = DiscordUtils.getServerIdFromMessage(context.message);

            var newTag: TagBlacklist = new TagBlacklist();

            newTag.idServer = idServer;
            newTag.tag = tag;

            newTag.save(function (err: Dynamic) {
                if (err != null) {
                    context.sendToChannel(l('fail', cast [author, err]));
                } else {
                    context.sendToChannel(l('success', cast [author]));
                }
            });
        } else {
            context.sendToChannel(l('wrong_format', cast [author]));
        }
    }
}
