package model.commandlist;

import utils.DiscordUtils;
import translations.LangCenter;
import external.discord.message.Message;
import model.entity.Meme;

class MemeList implements ICommandDefinition {
    public var paramsUsage = '';
    public var description: String;
    public var hidden = false;

    private var _splittedResult: Array<String>;
    private var _index: Int;
    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.memelist.description');
    }

    public function process(args: Array<String>): Void {
        Entity.getAll(Meme, function (memes: Array<Meme>): Void {
            var result: String = '';

            for (meme in memes) {
                result += '**\\`' + meme.name + '\\`** - ' + meme.description + ' \n';
            }

            _splittedResult = DiscordUtils.splitLongMessage(result);
            _index = 0;

            sendMessage(null, null);
        });
    }

    private function sendMessage(err: Dynamic, msg: Message): Void {
        if (_index > _splittedResult.length - 1) {
            _context.sendToChannel('model.commandlist.memelist.process.finished', cast [_context.getMessage().author]);
        } else {
            _index++;
            _context.rawSendToAuthor(_splittedResult[_index - 1], sendMessage);
        }
    }
}
