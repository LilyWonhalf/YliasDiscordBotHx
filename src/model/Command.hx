package model;

import utils.DiscordUtils;
import model.entity.Permission;
import js.html.Text;
import external.discord.channel.TextChannel;
import config.Config;
import utils.Logger;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import system.FileSystem;
import model.ICommandDefinition;
import external.discord.Server;
import external.discord.message.Message;

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

    public function process(msg: Message): Void {
        var content = msg.content;

        if (content.indexOf(Config.COMMAND_IDENTIFIER) == 0) {
            content = content.substr(Config.COMMAND_IDENTIFIER.length);
        }

        var args = content.split(' ');
        var command = args.shift().toLowerCase();

        if (_commands.exists(command)) {
            requestExecuteCommand(msg, command, args);
        } else {
            if (command == 'help') {
                displayHelpDialog(msg);
            } else {
                handleUnknownCommand(msg, command);
            }
        }
    }

    public function retrieveLastCommand(msg: Message): CommandCaller {
        var ret: CommandCaller = null;

        if (msg.channel.isPrivate) {
            if (_lastCommand.exists('0')) {
                ret = _lastCommand.get('0');
            }
        } else {
            var channel: TextChannel = cast msg.channel;

            if (_lastCommand.exists(channel.server.id)) {
                ret = _lastCommand.get(channel.server.id);
            }
        }

        return ret;
    }

    public function requestExecuteCommand(msg: Message, command: String, args: Array<String>): Void {
        if (command != '!') {
            var serverId: String = '0';

            if (!msg.channel.isPrivate) {
                var channel: TextChannel = cast msg.channel;
                serverId = channel.server.id;
            }

            Permission.check(msg.author.id, serverId, command, function (granted: Bool) {
                if (granted) {
                    _lastCommand.set(serverId, {
                        name: command,
                        args: args
                    });
                    var instance: ICommandDefinition = cast Type.createInstance(cast _commands.get(command), []);
                    instance.process(msg, args);
                } else {
                    var location = DiscordUtils.getLocationStringFromMessage(msg);
                    var client: Client = cast NodeJS.global.client;

                    Logger.notice('User ' + msg.author.username + ' (' + msg.author.id + ') tried to execute command ' + command + ' with arguments "' + args.join(' ') + '" but doesn\'t have rights.');
                    DiscordUtils.sendMessageToOwner(
                        L.a.n.g(
                            'model.command.requestexecutecommand.message_to_owner',
                            [
                                msg.author.username,
                                command,
                                args.join(' ')
                            ]
                        ) + '' + location
                    );
                    client.sendMessage(msg.channel, L.a.n.g('model.command.requestexecutecommand.message_to_member', cast [msg.author]));
                }
            });
        } else {
            var instance: ICommandDefinition = cast Type.createInstance(cast _commands.get(command), []);
            instance.process(msg, args);
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

        _commands.set('!', cast RepeatCommand);
    }

    private function displayHelpDialog(msg: Message): Void {
        var serverId: String = '0';
        var client: Client = cast NodeJS.global.client;

        if (!msg.channel.isPrivate) {
            var channel: TextChannel = cast msg.channel;
            serverId = channel.server.id;
        }

        Permission.getDeniedCommandList(msg.author.id, serverId, function (err: Dynamic, deniedCommandList: Array<String>) {
            if (err != null) {
                Logger.exception(err);
                client.sendMessage(msg.channel, L.a.n.g('model.command.displayhelpdialog.sql_error', cast [msg.author]));
            } else {
                var output: String = L.a.n.g('model.command.displayhelpdialog.introduction') + '\n\n\n';
                var content = new Array<String>();

                for (cmd in _commands.keys()) {
                    var instance: ICommandDefinition = cast Type.createInstance(cast _commands.get(cmd), []);

                    var hidden = instance.hidden;
                    var usage = instance.paramsUsage;
                    var description = instance.description;

                    if (!hidden && deniedCommandList.indexOf(cmd) < 0) {
                        output += '\t**!' + cmd + ' ' + usage + '**\n\t\t*' + description + '*\n\n';
                    }
                }

                output += '\n' + L.a.n.g('model.command.displayhelpdialog.end');
                content = DiscordUtils.splitLongMessage(output);

                sendHelpDialog(msg, content, 0, function (msg: Message) {
                    client.sendMessage(msg.channel, L.a.n.g('model.command.displayhelpdialog.message_to_member', cast [msg.author]));
                });
            }
        });
    }

    private function sendHelpDialog(msg: Message, content: Array<String>, index: Int, callback: Message->Void): Void {
        var client: Client = cast NodeJS.global.client;
        var messageSentCallback: Dynamic->Message->Void;

        if (index >= content.length - 1) {
            messageSentCallback = function(err: Dynamic, helpMsg: Message) {
                callback(msg);
            };
        } else {
            messageSentCallback = function(err: Dynamic, helpMsg: Message) {
                sendHelpDialog(msg, content, index + 1, callback);
            };
        }

        client.sendMessage(msg.author, content[index], cast {tts: false}, messageSentCallback);
    }

    private function handleUnknownCommand(msg: Message, command: String): Void {
        if (Config.ANSWER_TO_UNKNOWN_COMMAND) {
            var client: Client = cast NodeJS.global.client;
            client.sendMessage(msg.channel, L.a.n.g('model.command.handleunknowncommand.answer', cast [command, cast msg.author]));
        }
    }
}

class RepeatCommand implements ICommandDefinition {
    public var paramsUsage = '*(additionnal parameters)*';
    public var description = L.a.n.g('model.repeatcommand.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var lastCommand = Command.instance.retrieveLastCommand(msg);
        var client: Client = cast NodeJS.global.client;

        if (lastCommand == null) {
            client.sendMessage(msg.channel, L.a.n.g('model.repeatcommand.process.no_last_command', cast [msg.author]));
        } else {
            Command.instance.requestExecuteCommand(msg, lastCommand.name, lastCommand.args);
        }
    }
}

typedef CommandCaller = {
    name: String,
    args: Array<String>
}
