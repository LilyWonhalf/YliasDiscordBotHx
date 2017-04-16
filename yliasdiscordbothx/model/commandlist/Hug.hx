package yliasdiscordbothx.model.commandlist;

import discordbothx.core.DiscordBot;
import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.utils.YliasDiscordUtils;
import yliasdiscordbothx.utils.ArrayUtils;

class Hug extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '*(who)*';
    }

    override public function process(args: Array<String>): Void {
        var target: String = context.message.author.toString();
        var idServer = YliasDiscordUtils.getServerIdFromMessage(context.message);
        var hugs: Array<String>;
        var hug: String;

        if (args.length > 0) {
            target = args.join(' ');
        }

        if (target.indexOf(DiscordBot.instance.client.user.id) > -1) {
            hugs = [
                l('self_hug.1'),
                l('self_hug.2'),
                l('self_hug.3')
            ];
        } else {
            hugs = [
                l('hug.1', cast [target]),
                l('hug.2', cast [target]),
                l('hug.3', cast [target]),
                l('hug.4', cast [target]),
                l('hug.5', cast [target]),
                l('hug.6', cast [target]),
                l('hug.7', cast [target]),
                l('hug.8', cast [target]),
                l('hug.9', cast [target])
            ];
        }

        hug = ArrayUtils.random(hugs);
        context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
            'Hug',
            hug,
            Emotion.WINK
        ));
    }
}
