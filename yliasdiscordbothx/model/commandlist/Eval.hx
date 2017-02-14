package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.utils.DiscordUtils;
import discordbothx.log.Logger;

class Eval extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(javascript command)';
        nbRequiredParams = 1;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var output: String = null;
        var Db = Db.instance;

        Logger.info('User ' + author.username + ' (' +  author.id + ') executed eval with argument(s) "' + args.join(' ') + '".');

        try {
            output = untyped __js__('eval(args.join(\' \'))');
        } catch (e: Dynamic) {
            var idServer = DiscordUtils.getServerIdFromMessage(context.message);

            Logger.exception(e);
            output = l('exception', cast [author]);
        }

        context.sendToChannel(output);
    }
}
