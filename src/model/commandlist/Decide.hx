package model.commandlist;

import translations.LangCenter;
import utils.DiscordUtils;
import utils.Humanify;
import utils.ArrayUtils;
import translations.LangCenter;

class Decide implements ICommandDefinition {
    public var paramsUsage = '';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.decide.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;
        var idServer = DiscordUtils.getServerIdFromMessage(_context.getMessage());

        args = args.join(' ').split(' ' + LangCenter.instance.translate(idServer, 'model.commandlist.decide.process.split') + ' ');

        if (args.length > 1) {
            var picked = ArrayUtils.random(args);
            var sentence = LangCenter.instance.translate(idServer, Humanify.getChoiceDeliverySentence(), [picked]);

            _context.rawSendToChannel(author + ' => ' + sentence);
        } else {
            _context.sendToChannel('model.commandlist.decide.process.wrong_format', cast [author]);
        }
    }
}
