package yliasdiscordbothx.model;

import haxe.PosInfos;
import yliasdiscordbothx.translations.LangCenter;
import yliasdiscordbothx.utils.DiscordUtils;
import discordbothx.core.CommunicationContext;
import discordbothx.service.BaseCommand;

class YliasBaseCommand extends BaseCommand {
    public function new(context: CommunicationContext, ?pos: PosInfos) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.message);
        var commandName = pos.className.substr(pos.className.lastIndexOf('.') + 1).toLowerCase();

        description = LangCenter.instance.translate(serverId, 'yliasdiscordbothx.model.commandlist.' + commandName + '.description');
        super(context);
    }

    private function l(str: String, ?vars: Array<String>, variant: Int = 0, ?pos: PosInfos) {
        var commandName = pos.className.substr(pos.className.lastIndexOf('.') + 1).toLowerCase();

        return LangCenter.instance.translate(
            DiscordUtils.getServerIdFromMessage(context.message),
            'yliasdiscordbothx.model.commandlist.' + commandName + '.' + str,
            vars,
            variant
        );
    }
}