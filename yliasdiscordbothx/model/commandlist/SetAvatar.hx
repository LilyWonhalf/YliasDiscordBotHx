package yliasdiscordbothx.model.commandlist;

import discordbothx.core.DiscordBot;
import discordbothx.core.CommunicationContext;
import discordbothx.log.Logger;
import nodejs.Buffer;
import nodejs.NodeJS;

class SetAvatar extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(URL to the new avatar)';
        nbRequiredParams = 1;
    }

    override public function process(args: Array<String>): Void {
        var request = NodeJS.require('request');

        request(
            {
                url: args.join(' '),
                encoding: 'binary'
            },
            function (err: Dynamic, response: Dynamic, body: String) {
                if (err == null && response.statusCode == 200 && body.length > 0) {
                    DiscordBot.instance.client.user.setAvatar(new Buffer(body, 'binary')).catchError(function (error: Dynamic) {
                        if (error == null) {
                            context.sendToChannel(l('answer', cast [context.message.author]));
                        } else {
                            Logger.exception(error);
                            context.sendToChannel(l('fail', cast [context.message.author]));
                        }
                    });
                } else {
                    Logger.exception(err);
                    context.sendToChannel(l('network_error', cast [context.message.author]));
                }
            }
        );
    }
}
