package model.commandlist;

import utils.Logger;
import utils.Humanify;
import model.entity.Permission;
import utils.DiscordUtils;
import external.discord.channel.TextChannel;
import config.Config;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class RegisterPermission implements ICommandDefinition {
    public var paramsUsage = '(user ID) (command) (granted) *(server ID)*';
    public var description = L.a.n.g('model.commandlist.registerpermission.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;

        if (args.length > 2 && StringTools.trim(args[0]).length > 0 && StringTools.trim(args[1]).length > 0) {
            var idUser: String = StringTools.trim(args[0]);
            var command: String = StringTools.trim(args[1]);
            var granted: String = StringTools.trim(args[2]);
            var idServer: String = null;

            if (args.length > 3 && StringTools.trim(args[3]).length > 0) {
                idServer = StringTools.trim(args[3]);
            } else {
                if (msg.channel.isPrivate) {
                    idServer = Config.KEY_ALL;
                } else {
                    var channel: TextChannel = cast msg.channel;
                    idServer = channel.server.id;
                }
            }

            if (DiscordUtils.isHightlight(idUser)) {
                idUser = DiscordUtils.getIdFromHighlight(idUser);
            }

            if (idUser != null) {
                var realGranted: Bool = Humanify.getBooleanValue(granted);

                if (realGranted != null) {
                    var permission: Permission = new Permission();
                    var primaryValues = new Map<String, String>();

                    primaryValues.set('idUser', idUser);
                    primaryValues.set('idServer', idServer);
                    primaryValues.set('command', command);

                    permission.retrieve(primaryValues, function (found: Bool) {
                        if (!found) {
                            permission.idUser = idUser;
                            permission.command = command;
                            permission.idServer = idServer;
                        }

                        permission.granted = realGranted;

                        permission.save(function (err: Dynamic) {
                            if (err != null) {
                                Logger.exception(err);
                                client.sendMessage(msg.channel, L.a.n.g('model.commandlist.registerpermission.process.fail', cast [msg.author]));
                            } else {
                                client.sendMessage(msg.channel, L.a.n.g('model.commandlist.registerpermission.process.success', cast [msg.author]));
                            }
                        });
                    });
                } else {
                    Logger.debug(granted);
                    client.sendMessage(msg.channel, L.a.n.g('model.commandlist.registerpermission.process.granted_parse_error', cast [msg.author]));
                }
            } else {
                Logger.debug(idUser);
                client.sendMessage(msg.channel, L.a.n.g('model.commandlist.registerpermission.process.wrong_user', cast [msg.author]));
            }
        } else {
            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.registerpermission.process.wrong_format', cast [msg.author]));
        }
    }
}
