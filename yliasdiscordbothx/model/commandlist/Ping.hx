package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;

class Ping extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);
    }

    override public function process(args: Array<String>): Void {
        context.sendToChannel(':ping_pong: ' + l('answer', cast [context.message.author]));
    }
}
