package yliasdiscordbothx.model.commandlist;

import discordhx.channel.Channel;
import discordbothx.core.CommunicationContext;
import discordbothx.log.Logger;
import yliasdiscordbothx.utils.Humanify;
import yliasdiscordbothx.model.entity.Permission;
import yliasdiscordbothx.utils.DiscordUtils;
import discordhx.message.Message;

class RegisterPermission extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(user ID) (command) (granted) *(channel ID)*';
        nbRequiredParams = 3;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;

        if (args.length > 2 && StringTools.trim(args[0]).length > 0 && StringTools.trim(args[1]).length > 0) {
            var idUser: String = StringTools.trim(args[0]);
            var command: String = StringTools.trim(args[1]);
            var granted: String = StringTools.trim(args[2]);
            var idChannel: String = null;
            var idServer: String = DiscordUtils.getServerIdFromMessage(context.message);

            if (args.length > 3 && StringTools.trim(args[3]).length > 0) {
                idChannel = StringTools.trim(args[3]);
            } else {
                var channel: Channel = cast context.message.channel;
                idChannel = channel.id;
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
                                context.sendToChannel(l('fail', cast [author]));
                            } else {
                                context.sendToChannel(l('success', cast [author]));
                            }
                        });
                    });
                } else {
                    Logger.debug(granted);
                    context.sendToChannel(l('granted_parse_error', cast [author]));
                }
            } else {
                Logger.debug(idUser);
                context.sendToChannel(l('wrong_user', cast [author]));
            }
        } else {
            context.sendToChannel(l('wrong_format', cast [author]));
        }
    }
}
