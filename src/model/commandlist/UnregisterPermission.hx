package model.commandlist;

import utils.Logger;
import model.entity.Permission;
import utils.DiscordUtils;
import discordhx.channel.TextChannel;
import config.Config;
import translations.LangCenter;

class UnregisterPermission implements ICommandDefinition {
    public var paramsUsage = '(user ID) (command) *(channel ID)*';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.unregisterpermission.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        if (args.length > 1 && StringTools.trim(args[0]).length > 0 && StringTools.trim(args[1]).length > 0) {
            var idUser: String = StringTools.trim(args[0]);
            var command: String = StringTools.trim(args[1]);
            var idChannel: String = null;
            var idServer: String = DiscordUtils.getServerIdFromMessage(_context.getMessage());

            if (args.length > 2 && StringTools.trim(args[2]).length > 0) {
                idChannel = StringTools.trim(args[2]);
            } else {
                idChannel = _context.getMessage().channel.id;
            }

            if (DiscordUtils.isHightlight(idUser)) {
                idUser = DiscordUtils.getIdFromHighlight(idUser);
            }

            if (idUser != null) {
                var permission: Permission = new Permission();
                var primaryValues = new Map<String, String>();

                primaryValues.set('idUser', idUser);
                primaryValues.set('idChannel', idChannel);
                primaryValues.set('idServer', idServer);
                primaryValues.set('command', command);

                permission.retrieve(primaryValues, function (found: Bool) {
                    if (found) {
                        permission.remove(function (err: Dynamic) {
                            if (err != null) {
                                Logger.exception(err);
                                _context.sendToChannel('model.commandlist.unregisterpermission.process.fail', cast [author]);
                            } else {
                                _context.sendToChannel('model.commandlist.unregisterpermission.process.success', cast [author]);
                            }
                        });
                    } else {
                        _context.sendToChannel('model.commandlist.unregisterpermission.process.not_found', cast [author]);
                    }
                });
            } else {
                _context.sendToChannel('model.commandlist.unregisterpermission.process.wrong_user', cast [author]);
            }
        } else {
            _context.sendToChannel('model.commandlist.unregisterpermission.process.wrong_format', cast [author]);
        }
    }
}
