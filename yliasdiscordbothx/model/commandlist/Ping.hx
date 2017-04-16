package yliasdiscordbothx.model.commandlist;

import yliasdiscordbothx.utils.YliasDiscordUtils;
import discordbothx.core.CommunicationContext;

class Ping extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);
    }

    override public function process(args: Array<String>): Void {
        context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
            'Ping',
            l('answer', cast [context.message.author]) + ':ping_pong: ',
            Emotion.NEUTRAL
        ));
    }
}
