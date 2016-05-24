package model.commandlist;

import utils.DiscordUtils;
import utils.Logger;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;
import model.entity.Meme;

class MemeList implements ICommandDefinition {
    public var paramsUsage = '';
    public var description = L.a.n.g('model.commandlist.memelist.description');
    public var hidden = false;

    private var _splittedResult: Array<String>;
    private var _index: Int;
    private var _msg: Message;

    public function process(msg: Message, args: Array<String>): Void {
        Entity.getAll(Meme, function (memes: Array<Meme>): Void {
            var result: String = '';

            for (meme in memes) {
                result += '**\\`' + meme.name + '\\`** - ' + meme.description + ' \n';
            }

            _splittedResult = DiscordUtils.splitLongMessage(result);
            _index = 0;
            _msg = msg;

            sendMessage(null, null);
        });
    }

    private function sendMessage(err: Dynamic, msg: Message): Void {
        var client: Client = cast NodeJS.global.client;

        if (_index > _splittedResult.length - 1) {
            client.sendMessage(_msg.channel, L.a.n.g('model.commandlist.memelist.process.finished', cast [_msg.author]));
        } else {
            _index++;
            client.sendMessage(_msg.author, _splittedResult[_index - 1], cast {tts: false}, sendMessage);
        }
    }
}
