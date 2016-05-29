package model.commandlist;

import utils.DiscordUtils;
import StringTools;
import translations.LangCenter;

class SetLang implements ICommandDefinition {
    public var paramsUsage = '(lang)';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.setlang.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        if (args.length > 0) {
            var lang: String = StringTools.trim(args[0]);
            var langList: Array<String> = cast [
                Lang.fr_FR,
                Lang.en_GB
            ];

            if (langList.indexOf(lang) > -1) {
                var serverId = DiscordUtils.getServerIdFromMessage(_context.getMessage());

                LangCenter.instance.setLang(serverId, cast lang);
                _context.sendToChannel('model.commandlist.setlang.process.answer', cast [author]);
            } else {
                _context.sendToChannel('model.commandlist.setlang.process.wrong_lang', cast [author]);
            }
        } else {
            _context.sendToChannel('model.commandlist.setlang.process.wrong_format', cast [author]);
        }
    }
}
