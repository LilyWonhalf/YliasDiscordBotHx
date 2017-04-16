package yliasdiscordbothx.model.commandlist;

import discordbothx.service.DiscordUtils;
import discordhx.RichEmbed;
import discordbothx.core.CommunicationContext;
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
        var embed: RichEmbed = new RichEmbed();
        var Db = Db.instance;

        Logger.info('User ' + author.username + ' (' +  author.id + ') executed eval with argument(s) "' + args.join(' ') + '".');

        try {
            output = untyped __js__('eval(args.join(\' \'))');
            embed.setTitle(String.fromCharCode(55357) + String.fromCharCode(56833) + ' Code executed');
        } catch (e: Dynamic) {
            Logger.exception(e);

            output = cast e;
            embed.setTitle(String.fromCharCode(55357) + String.fromCharCode(56881) + ' Code failed');
        }

        embed.setColor(DiscordUtils.getMaterialUIColor());
        embed.setDescription('\n**Input:**\n```js\n' + args.join(' ') + '\n```\n**Output:**\n```\n' + output + '\n```');

        context.sendEmbedToChannel(embed);
    }
}
