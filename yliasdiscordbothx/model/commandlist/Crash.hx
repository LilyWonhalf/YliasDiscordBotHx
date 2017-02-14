package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;

class Crash extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);
    }

    override public function process(args: Array<String>): Void {
        context.sendToChannel(l('speech'));
        untyped __js__('setTimeout(() => crash++, 1000)');
    }
}
