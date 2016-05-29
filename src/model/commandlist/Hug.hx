package model.commandlist;

import utils.DiscordUtils;
import utils.ArrayUtils;
import translations.LangCenter;

class Hug implements ICommandDefinition {
    public var paramsUsage = '*(who)*';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.hug.description');
    }

    public function process(args: Array<String>): Void {
        var target: String = _context.getMessage().author.mention();
        var idServer = DiscordUtils.getServerIdFromMessage(_context.getMessage());
        var hugs: Array<String>;
        var hug: String;

        if (args.length > 0) {
            target = args.join(' ');
        }

        if (target.indexOf(Core.userInstance.id) > -1) {
            hugs = [
                LangCenter.instance.translate(idServer, 'model.commandlist.hug.process.self_hug.1'),
                LangCenter.instance.translate(idServer, 'model.commandlist.hug.process.self_hug.2'),
                LangCenter.instance.translate(idServer, 'model.commandlist.hug.process.self_hug.3')
            ];
        } else {
            hugs = [
                LangCenter.instance.translate(idServer, 'model.commandlist.hug.process.hug.1', cast [target]),
                LangCenter.instance.translate(idServer, 'model.commandlist.hug.process.hug.2', cast [target]),
                LangCenter.instance.translate(idServer, 'model.commandlist.hug.process.hug.3', cast [target]),
                LangCenter.instance.translate(idServer, 'model.commandlist.hug.process.hug.4', cast [target]),
                LangCenter.instance.translate(idServer, 'model.commandlist.hug.process.hug.5', cast [target]),
                LangCenter.instance.translate(idServer, 'model.commandlist.hug.process.hug.6', cast [target]),
                LangCenter.instance.translate(idServer, 'model.commandlist.hug.process.hug.7', cast [target]),
                LangCenter.instance.translate(idServer, 'model.commandlist.hug.process.hug.8', cast [target]),
                LangCenter.instance.translate(idServer, 'model.commandlist.hug.process.hug.9', cast [target])
            ];
        }

        hug = ArrayUtils.random(hugs);
        _context.rawSendToChannel(hug);
    }
}
