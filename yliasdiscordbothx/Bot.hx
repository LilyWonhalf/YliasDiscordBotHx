package yliasdiscordbothx;

import yliasdiscordbothx.model.Db;
import yliasdiscordbothx.model.PermissionSystem;
import yliasdiscordbothx.utils.DiscordUtils;
import yliasdiscordbothx.system.FileSystem;
import yliasdiscordbothx.translations.LangCenter;
import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.event.ClientEventHandler;
import yliasdiscordbothx.config.AuthDetails;
import discordbothx.core.DiscordBot;

class Bot {
    public static var instance(get, null): Bot;

    public var authDetails: AuthDetails;

    public static function main() {
        instance = new Bot();
    }

    public static function get_instance(): Bot {
        if (instance == null) {
            instance;
        }

        return instance;
    }

    private function new() {
        var bot: DiscordBot = DiscordBot.instance;
        var clientEventHandler: ClientEventHandler = null;

        authDetails = new AuthDetails();
        bot.authDetails = authDetails;
        bot.permissionSystem = new PermissionSystem();
        bot.helpDialogHeader = function (context: CommunicationContext): String {
            var serverId: String = DiscordUtils.getServerIdFromMessage(context.message);
            return LangCenter.instance.translate(serverId, 'helpdialogintroduction');
        };
        bot.helpDialogFooter = function (context: CommunicationContext): String {
            var serverId: String = DiscordUtils.getServerIdFromMessage(context.message);
            return LangCenter.instance.translate(serverId, 'helpdialogend');
        };

        var commandList: Array<String> = FileSystem.getFileListInFolder('yliasdiscordbothx/model/commandlist/');

        for (command in commandList) {
            var commandName = command.substr(0, command.lastIndexOf('.'));

            bot.commands.set(
                commandName.toLowerCase(),
                cast Type.resolveClass('yliasdiscordbothx.model.commandlist.' + commandName)
            );
        }

        clientEventHandler = new ClientEventHandler(bot.client);

        bot.login();
    }
}
