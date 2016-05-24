package model.commandlist;

import utils.Logger;
import model.entity.Permission;
import utils.DiscordUtils;
import external.discord.channel.TextChannel;
import config.Config;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class UnregisterPermission implements ICommandDefinition {
    public var paramsUsage = '(user ID) (command) *(server ID)*';
    public var description = L.a.n.g('model.commandlist.unregisterpermission.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;

        if (args.length > 1 && StringTools.trim(args[0]).length > 0 && StringTools.trim(args[1]).length > 0) {
            var idUser: String = StringTools.trim(args[0]);
            var command: String = StringTools.trim(args[1]);
            var idServer: String = null;

            if (args.length > 2 && StringTools.trim(args[2]).length > 0) {
                idServer = StringTools.trim(args[2]);
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
                var permission: Permission = new Permission();
                var primaryValues = new Map<String, String>();

                primaryValues.set('idUser', idUser);
                primaryValues.set('idServer', idServer);
                primaryValues.set('command', command);

                permission.retrieve(primaryValues, function (found: Bool) {
                    if (found) {
                        permission.remove(function (err: Dynamic) {
                            if (err != null) {
                                Logger.exception(err);
                                client.sendMessage(msg.channel, L.a.n.g('model.commandlist.unregisterpermission.process.fail', cast [msg.author]));
                            } else {
                                client.sendMessage(msg.channel, L.a.n.g('model.commandlist.unregisterpermission.process.success', cast [msg.author]));
                            }
                        });
                    } else {
                        client.sendMessage(msg.channel, L.a.n.g('model.commandlist.unregisterpermission.process.not_found', cast [msg.author]));
                    }
                });
            } else {
                client.sendMessage(msg.channel, L.a.n.g('model.commandlist.unregisterpermission.process.wrong_user', cast [msg.author]));
            }
        } else {
            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.unregisterpermission.process.wrong_format', cast [msg.author]));
        }
    }
}
