package yliasdiscordbothx.model.commandlist;

import discordhx.channel.Channel;
import discordbothx.core.CommunicationContext;
import discordbothx.log.Logger;
import yliasdiscordbothx.utils.Humanify;
import yliasdiscordbothx.model.entity.Permission;
import yliasdiscordbothx.utils.YliasDiscordUtils;
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
            var idServer: String = YliasDiscordUtils.getServerIdFromMessage(context.message);

            if (args.length > 3 && StringTools.trim(args[3]).length > 0) {
                idChannel = StringTools.trim(args[3]);
            } else {
                var channel: Channel = cast context.message.channel;
                idChannel = channel.id;
            }

            if (YliasDiscordUtils.isHightlight(idUser)) {
                idUser = YliasDiscordUtils.getIdFromHighlight(idUser);
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
                                context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                                    'Register permission',
                                    YliasDiscordUtils.getCleanString(context, l('fail', cast [author])),
                                    Emotion.SAD
                                ));
                            } else {
                                context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                                    'Register permission',
                                    YliasDiscordUtils.getCleanString(context, l('success', cast [author])),
                                    Emotion.NEUTRAL
                                ));
                            }
                        });
                    });
                } else {
                    Logger.debug(granted);
                    context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                        'Register permission',
                        YliasDiscordUtils.getCleanString(context, l('granted_parse_error', cast [author])),
                        Emotion.UNAMUSED
                    ));
                }
            } else {
                Logger.debug(idUser);
                context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                    'Register permission',
                    YliasDiscordUtils.getCleanString(context, l('wrong_user', cast [author])),
                    Emotion.NEUTRAL
                ));
            }
        } else {
            context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                'Register permission',
                YliasDiscordUtils.getCleanString(context, l('wrong_format', cast [author])),
                Emotion.UNAMUSED
            ));
        }
    }
}
