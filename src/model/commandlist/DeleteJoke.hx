package model.commandlist;

import utils.DiscordUtils;
import utils.Logger;
import model.entity.Joke;
import translations.LangCenter;

class DeleteJoke implements ICommandDefinition {
    public var paramsUsage = '(the joke ID)';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.deletejoke.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        if (args.length > 0) {
            var joke: Joke = new Joke();
            var primaryValues = new Map<String, String>();

            primaryValues.set('id', cast Std.parseInt(args[0]));

            joke.retrieve(primaryValues, function(found: Bool) {
                if (!found) {
                    _context.sendToChannel('model.commandlist.deletejoke.process.not_found', cast [author]);
                } else {
                    joke.remove(function (err: Dynamic) {
                        if (err != null) {
                            Logger.exception(err);
                            _context.sendToChannel('model.commandlist.deletejoke.process.failed', cast [author]);
                        } else {
                            _context.sendToChannel('model.commandlist.deletejoke.process.success', cast [author]);
                        }
                    });
                }
            });
        } else {
            _context.sendToChannel('model.commandlist.deletejoke.process.wong_format', cast [author]);
        }
    }
}
