package yliasdiscordbothx.model.commandlist;

import yliasdiscordbothx.utils.YliasDiscordUtils;
import discordbothx.core.CommunicationContext;

class Crash extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);
    }

    override public function process(args: Array<String>): Void {
        context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
            'Crash',
            l('speech'),
            Emotion.UNAMUSED
        ));
        untyped __js__('setTimeout(() => crash++, 1000)');
    }
}
