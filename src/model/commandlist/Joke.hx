package model.commandlist;

import utils.DiscordUtils;
import translations.LangCenter;
import model.entity.Joke as JokeEntity;

class Joke implements ICommandDefinition {
    public var paramsUsage = '*(search word 1)* *(search word 2)* *(search word n)*';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.joke.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        if (args.length == 1 && !Math.isNaN(cast args[0])) {
            var joke = new JokeEntity();
            var primaryValues = new Map<String, String>();

            primaryValues.set('id', cast Std.parseInt(args[0]));

            joke.retrieve(primaryValues, function (found) {
                if (found) {
                    _context.sendToChannel('model.commandlist.joke.process.answer', cast [cast author, cast joke.id, joke.content]);
                } else {
                    JokeEntity.getRandom(args, function (joke: JokeEntity) {
                        if (joke != null) {
                            _context.sendToChannel('model.commandlist.joke.process.answer', cast [cast author, cast joke.id, joke.content]);
                        } else {
                            _context.sendToChannel('model.commandlist.joke.process.not_found', cast [author]);
                        }
                    });
                }
            });
        } else {
            JokeEntity.getRandom(args, function (joke: JokeEntity) {
                if (joke != null) {
                    _context.sendToChannel('model.commandlist.joke.process.answer', cast [cast author, cast joke.id, joke.content]);
                } else {
                    _context.sendToChannel('model.commandlist.joke.process.not_found', cast [author]);
                }
            });
        }
    }
}
