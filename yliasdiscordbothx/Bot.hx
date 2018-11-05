package yliasdiscordbothx;

import yliasdiscordbothx.config.Config;
import discordbothx.event.NotificationBus;
import yliasdiscordbothx.model.PermissionSystem;
import yliasdiscordbothx.utils.YliasDiscordUtils;
import yliasdiscordbothx.system.FileSystem;
import yliasdiscordbothx.translations.LangCenter;
import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.event.ClientEventHandler;
import yliasdiscordbothx.config.AuthDetails;
import discordbothx.core.DiscordBot;

class Bot {
    public static inline var PROJECT_NAME = 'yliasdiscordbothx';

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
            var serverId: String = YliasDiscordUtils.getServerIdFromMessage(context.message);
            return LangCenter.instance.translate(serverId, 'helpdialogintroduction');
        };
        bot.helpDialogFooter = function (context: CommunicationContext): String {
            var serverId: String = YliasDiscordUtils.getServerIdFromMessage(context.message);
            return LangCenter.instance.translate(serverId, 'helpdialogend');
        };
        bot.commandIdentifier = Config.COMMAND_IDENTIFIER;

        var commandList: Array<String> = FileSystem.getFileListInFolder('yliasdiscordbothx/model/commandlist');

        for (command in commandList) {
            var commandName = command.substr(0, command.lastIndexOf('.'));

            bot.commands.set(
                commandName.toLowerCase(),
                cast Type.resolveClass(PROJECT_NAME + '.model.commandlist.' + commandName)
            );
        }

        clientEventHandler = new ClientEventHandler(bot.client);

        bindSignals();
        bot.login();
    }

    private function bindSignals(): Void {
        NotificationBus.instance.cleverbotErrorNotReady.add(function (context: CommunicationContext): Void {
            var serverId: String = YliasDiscordUtils.getServerIdFromMessage(context.message);
            var author: String = context.message.author.toString();

            context.sendToChannel(LangCenter.instance.translate(serverId, 'cleverbotio_not_ready', [author]));
        });
        NotificationBus.instance.cleverbotErrorBotSuspected.add(function (context: CommunicationContext): Void {
            var serverId: String = YliasDiscordUtils.getServerIdFromMessage(context.message);
            var author: String = context.message.author.username;

            context.sendToChannel(LangCenter.instance.translate(serverId, 'cleverbotio_bot_suspected', [author]));
        });

        NotificationBus.instance.checkPermissionError.add(function (context: CommunicationContext, command: String): Void {
            var serverId: String = YliasDiscordUtils.getServerIdFromMessage(context.message);
            var author: String = context.message.author.toString();

            context.sendToChannel(LangCenter.instance.translate(serverId, 'check_permission_error', [author]));
        });
        NotificationBus.instance.getDeniedCommandListError.add(function (context: CommunicationContext): Void {
            var serverId: String = YliasDiscordUtils.getServerIdFromMessage(context.message);
            var author: String = context.message.author.toString();

            context.sendToChannel(LangCenter.instance.translate(serverId, 'get_denied_command_list_error', [author]));
        });

        NotificationBus.instance.noLastCommand.add(function (context: CommunicationContext): Void {
            var serverId: String = YliasDiscordUtils.getServerIdFromMessage(context.message);
            var author: String = context.message.author.toString();

            context.sendToChannel(LangCenter.instance.translate(serverId, 'no_last_command', [author]));
        });
        NotificationBus.instance.unauthorizedCommand.add(function (context: CommunicationContext, command: String): Void {
            var serverId: String = YliasDiscordUtils.getServerIdFromMessage(context.message);
            var author: String = context.message.author.toString();
            var args: String = context.message.content.split(' ').slice(1).join(' ');

            context.sendToChannel(LangCenter.instance.translate(serverId, 'unauthorized_command_message_to_member', [author]));
            context.sendToOwner(
                LangCenter.instance.translate(
                    serverId,
                    'unauthorized_command_message_to_owner',
                    [author, command, args, YliasDiscordUtils.getLocationStringFromMessage(context.message)]
                )
            );
        });
        NotificationBus.instance.unknownCommand.add(function (context: CommunicationContext, command: String): Void {
            var serverId: String = YliasDiscordUtils.getServerIdFromMessage(context.message);
            var author: String = context.message.author.toString();

            if (Config.ANSWER_TO_UNKNOWN_COMMAND) {
                context.sendToChannel(LangCenter.instance.translate(serverId, 'unknown_command', [command, author, Config.COMMAND_IDENTIFIER]));
            }
        });

        NotificationBus.instance.helpDialogSent.add(function (context: CommunicationContext): Void {
            var serverId: String = YliasDiscordUtils.getServerIdFromMessage(context.message);
            var author: String = context.message.author.toString();

            context.sendToChannel(LangCenter.instance.translate(serverId, 'help_dialog_sent_confirmation', [author]));
        });
        NotificationBus.instance.sendHelpDialogError.add(function (context: CommunicationContext): Void {
            var serverId: String = YliasDiscordUtils.getServerIdFromMessage(context.message);
            var author: String = context.message.author.toString();

            context.sendToChannel(LangCenter.instance.translate(serverId, 'help_dialog_send_error', [author]));
        });
    }
}
