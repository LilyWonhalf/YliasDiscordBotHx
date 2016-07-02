package model;

import utils.DiscordUtils;
import model.entity.Permission;
import js.html.Text;
import discordhx.channel.TextChannel;
import config.Config;
import utils.Logger;
import translations.LangCenter;
import nodejs.NodeJS;
import discordhx.client.Client;
import system.FileSystem;
import model.ICommandDefinition;
import discordhx.Server;
import discordhx.message.Message;

class Command {
    public static var instance(get, null): Command;

    private static var _instance: Command;

    private var _lastCommand: Map<String, CommandCaller>;
    private var _commands: Map<String, ICommandDefinition>;

    public static function get_instance(): Command {
        if (_instance == null) {
            _instance = new Command();
        }

        return _instance;
    }

    public function process(context: CommunicationContext): Void {
        var msg: Message = context.getMessage();
        var content = msg.content;

        if (content.indexOf(Config.COMMAND_IDENTIFIER) == 0) {
            content = content.substr(Config.COMMAND_IDENTIFIER.length);
        }

        var args = content.split(' ');
        var command = args.shift().toLowerCase();

        if (_commands.exists(command)) {
            requestExecuteCommand(context, command, args);
        } else {
            if (command == 'help') {
                displayHelpDialog(context);
            } else {
                handleUnknownCommand(context, command);
            }
        }
    }

    public function requestExecuteLastCommand(context: CommunicationContext, additionnalArgs: Array<String>): Void {
        var lastCommand = retrieveLastCommand(context);

        if (lastCommand == null) {
            context.sendToChannel('model.repeatcommand.process.no_last_command', cast [context.getMessage().author]);
        } else {
            requestExecuteCommand(context, lastCommand.name, lastCommand.args.concat(additionnalArgs));
        }
    }

    private function retrieveLastCommand(context: CommunicationContext): CommandCaller {
        var ret: CommandCaller = null;

        if (_lastCommand.exists(context.getMessage().channel.id)) {
            ret = _lastCommand.get(context.getMessage().channel.id);
        }

        return ret;
    }

    private function requestExecuteCommand(context: CommunicationContext, command: String, args: Array<String>): Void {
        if (command != Config.COMMAND_IDENTIFIER) {
            var author = context.getMessage().author;
            var serverId: String = DiscordUtils.getServerIdFromMessage(context.getMessage());

            Permission.check(author.id, context.getMessage().channel.id, serverId, command, function (granted: Bool) {
                if (granted) {
                    _lastCommand.set(context.getMessage().channel.id, {
                        name: command,
                        args: args
                    });
                    var instance: ICommandDefinition = cast Type.createInstance(cast _commands.get(command), [context]);
                    instance.process(args);
                } else {
                    var location = DiscordUtils.getLocationStringFromMessage(context.getMessage());

                    Logger.notice('User ' + author.username + ' (' + author.id + ') tried to execute command ' + command + ' with arguments "' + args.join(' ') + '" but doesn\'t have rights.');

                    context.sendToOwner('model.command.requestexecutecommand.message_to_owner', cast [author.username, command, args.join(' '), location]);
                    context.sendToChannel('model.command.requestexecutecommand.message_to_member', cast [author]);
                }
            });
        } else {
            var instance: ICommandDefinition = cast Type.createInstance(cast _commands.get(command), [context]);
            instance.process(args);
        }
    }

    private function new() {
        _lastCommand = new Map<String, CommandCaller>();
        _commands = new Map<String, ICommandDefinition>();

        var commandList: Array<String> = FileSystem.getFileListInFolder('model/commandlist/');

        for (command in commandList) {
            var commandName = command.substr(0, command.lastIndexOf('.'));

            _commands.set(commandName.toLowerCase(), cast Type.resolveClass('model.commandlist.' + commandName));
        }

        _commands.set(Config.COMMAND_IDENTIFIER, cast RepeatCommand);
    }

    private function displayHelpDialog(context: CommunicationContext): Void {
        var serverId: String = DiscordUtils.getServerIdFromMessage(context.getMessage());
        var author = context.getMessage().author;

        Permission.getDeniedCommandList(author.id, context.getMessage().channel.id, serverId, function (err: Dynamic, deniedCommandList: Array<String>) {
            if (err != null) {
                Logger.exception(err);
                context.sendToChannel('model.command.displayhelpdialog.sql_error', cast [author]);
            } else {
                var output: String = LangCenter.instance.translate(serverId, 'model.command.displayhelpdialog.introduction') + '\n\n\n';
                var content = new Array<String>();

                for (cmd in _commands.keys()) {
                    var instance: ICommandDefinition = cast Type.createInstance(cast _commands.get(cmd), [context]);

                    var hidden = instance.hidden;
                    var usage = instance.paramsUsage;
                    var description = instance.description;

                    if (!hidden && deniedCommandList.indexOf(cmd) < 0) {
                        output += '\t**' + Config.COMMAND_IDENTIFIER + cmd + ' ' + usage + '**\n\t\t*' + description + '*\n\n';
                    }
                }

                output += '\n' + LangCenter.instance.translate(serverId, 'model.command.displayhelpdialog.end');
                content = DiscordUtils.splitLongMessage(output);

                sendHelpDialog(context, content, 0, function (context: CommunicationContext) {
                    context.sendToChannel('model.command.displayhelpdialog.message_to_member', cast [author]);
                });
            }
        });
    }

    private function sendHelpDialog(context: CommunicationContext, content: Array<String>, index: Int, callback: CommunicationContext->Void): Void {
        var messageSentCallback: Dynamic->Message->Void;

        if (index >= content.length - 1) {
            messageSentCallback = function(err: Dynamic, msg: Message) {
                callback(context);
            };
        } else {
            messageSentCallback = function(err: Dynamic, msg: Message) {
                sendHelpDialog(context, content, index + 1, callback);
            };
        }

        context.rawSendToAuthor(content[index], messageSentCallback);
    }

    private function handleUnknownCommand(context: CommunicationContext, command: String): Void {
        if (Config.ANSWER_TO_UNKNOWN_COMMAND) {
            context.sendToChannel('model.command.handleunknowncommand.answer', cast [command, cast context.getMessage().author]);
        }
    }
}

class RepeatCommand implements ICommandDefinition {
    public var paramsUsage = '*(additionnal parameters)*';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.repeatcommand.description');
    }

    public function process(args: Array<String>): Void {
        Command.instance.requestExecuteLastCommand(_context, args);
    }
}

typedef CommandCaller = {
    name: String,
    args: Array<String>
}
