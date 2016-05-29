package model.commandlist;

import utils.DiscordUtils;
import utils.Logger;
import model.entity.Joke;
import translations.LangCenter;

class AddJoke implements ICommandDefinition {
    public var paramsUsage = '(the joke)';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.addjoke.description');
    }

    public function process(args: Array<String>): Void {
        var joke = new Joke();
        var author = _context.getMessage().author;

        joke.content = args.join(' ');
        joke.save(function (err) {
            if (err != null) {
                Logger.exception(err);
                _context.sendToChannel('model.commandlist.addjoke.fail', cast [author]);
            } else {
                _context.sendToChannel('model.commandlist.addjoke.success', cast [author]);
            }
        });
    }
}
