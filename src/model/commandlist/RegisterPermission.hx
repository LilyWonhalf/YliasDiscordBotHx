package model.commandlist;

import utils.Logger;
import utils.Humanify;
import model.entity.Permission;
import utils.DiscordUtils;
import translations.LangCenter;
import discordhx.message.Message;

class RegisterPermission implements ICommandDefinition {
    public var paramsUsage = '(user ID) (command) (granted) *(channel ID)*';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.registerpermission.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;

        if (args.length > 2 && StringTools.trim(args[0]).length > 0 && StringTools.trim(args[1]).length > 0) {
            var idUser: String = StringTools.trim(args[0]);
            var command: String = StringTools.trim(args[1]);
            var granted: String = StringTools.trim(args[2]);
            var idChannel: String = null;
            var idServer: String = DiscordUtils.getServerIdFromMessage(_context.getMessage());

            if (args.length > 3 && StringTools.trim(args[3]).length > 0) {
                idChannel = StringTools.trim(args[3]);
            } else {
                idChannel = _context.getMessage().channel.id;
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
                    primaryValues.set('idChannel', idChannel);
                    primaryValues.set('idServer', idServer);
                    primaryValues.set('command', command);

                    permission.retrieve(primaryValues, function (found: Bool) {
                        if (!found) {
                            permission.idUser = idUser;
                            permission.command = command;
                            permission.idChannel = idChannel;
                            permission.idServer = idServer;
                        }

                        permission.granted = realGranted;

                        permission.save(function (err: Dynamic) {
                            if (err != null) {
                                Logger.exception(err);
                                _context.sendToChannel('model.commandlist.registerpermission.process.fail', cast [author]);
                            } else {
                                _context.sendToChannel('model.commandlist.registerpermission.process.success', cast [author]);
                            }
                        });
                    });
                } else {
                    Logger.debug(granted);
                    _context.sendToChannel('model.commandlist.registerpermission.process.granted_parse_error', cast [author]);
                }
            } else {
                Logger.debug(idUser);
                _context.sendToChannel('model.commandlist.registerpermission.process.wrong_user', cast [author]);
            }
        } else {
            _context.sendToChannel('model.commandlist.registerpermission.process.wrong_format', cast [author]);
        }
    }
}
