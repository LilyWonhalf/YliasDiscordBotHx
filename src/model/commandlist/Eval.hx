package model.commandlist;

import utils.DiscordUtils;
import utils.Logger;
import translations.LangCenter;

class Eval implements ICommandDefinition {
    public var paramsUsage = ' (javascript command)';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.eval.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;
        var output: String;
        var Db = Db.instance;

        Logger.info('User ' + author.username + ' (' +  author.id + ') executed eval with argument(s) "' + args.join(' ') + '".');

        try {
            output = untyped __js__('eval(args.join(\' \'))');
        } catch (e: Dynamic) {
            var idServer = DiscordUtils.getServerIdFromMessage(_context.getMessage());

            Logger.exception(e);
            output = LangCenter.instance.translate(idServer, 'model.commandlist.eval.process.exception', cast [author]);
        }

        _context.rawSendToChannel(output);
    }
}
