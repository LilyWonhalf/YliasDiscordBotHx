package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import discordbothx.service.DiscordUtils as RootDiscordUtils;
import discordhx.message.Message;
import yliasdiscordbothx.model.entity.Meme;

class MemeList extends YliasBaseCommand {
    private var splittedResult: Array<String>;
    private var index: Int;

    public function new(context: CommunicationContext) {
        super(context);
    }

    override public function process(args: Array<String>): Void {
        Entity.getAll(Meme, function (memes: Array<Meme>): Void {
            var result: String = '';

            for (meme in memes) {
                result += '**\\`' + meme.name + '\\`** - ' + meme.description + ' \n';
            }

            splittedResult = RootDiscordUtils.splitLongMessage(result);
            index = 0;

            sendMessage(null);
        });
    }

    private function sendMessage(msg: Message): Void {
        if (index > splittedResult.length - 1) {
            context.sendToChannel(l('finished', cast [context.message.author]));
        } else {
            index++;
            context.sendToAuthor(splittedResult[index - 1]).then(sendMessage);
        }
    }
}
