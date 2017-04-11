package yliasdiscordbothx.model.commandlist;

import discordbothx.core.DiscordBot;
import discordbothx.core.CommunicationContext;
import discordbothx.log.Logger;

class SetAvatar extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(URL to the new avatar)';
        nbRequiredParams = 1;
    }

    override public function process(args: Array<String>): Void {
        DiscordBot.instance.client.user.setAvatar(args.join(' ')).catchError(function (error: Dynamic) {
            if (error == null) {
                context.sendToChannel(l('answer', cast [context.message.author]));
            } else {
                Logger.exception(error);
                context.sendToChannel(l('fail', cast [context.message.author]));
            }
        });
    }
}
