package yliasdiscordbothx.model.commandlist;

import discordhx.channel.ChannelType;
import discordhx.channel.Channel;
import discordbothx.core.CommunicationContext;
import discordbothx.log.Logger;
import yliasdiscordbothx.model.entity.Staff;
import yliasdiscordbothx.utils.YliasDiscordUtils;
import discordhx.user.User;
import discordhx.message.Message;

class RegisterStaff extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(mention of the new staff member)';
        nbRequiredParams = 1;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var userlist: Array<User> = null;
        var channel: Channel = cast context.message.channel;

        if (channel.type != ChannelType.DM) {
            var staff = new Staff();
            var staffMember = context.message.mentions.users.first();
            var serverId = YliasDiscordUtils.getServerIdFromMessage(context.message);
            var uniqueValues = new Map<String, String>();

            uniqueValues.set('idUser', staffMember.id);
            uniqueValues.set('idServer', serverId);

            staff.retrieve(uniqueValues, function (found: Bool): Void {
                if (!found) {
                    staff.idUser = staffMember.id;
                    staff.idServer = serverId;
                }

                staff.notifyNewMember = true;
                staff.save(function (err: Dynamic): Void {
                    if (err == null) {
                        context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                            'Register staff',
                            YliasDiscordUtils.getCleanString(context, l('success', cast [author])),
                            Emotion.NEUTRAL
                        ));
                    } else {
                        Logger.exception(err);
                        context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                            'Register staff',
                            YliasDiscordUtils.getCleanString(context, l('fail', cast [author])),
                            Emotion.SAD
                        ));
                    }
                });
            });
        } else {
            context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                'Register staff',
                YliasDiscordUtils.getCleanString(context, l('private_channel_error', cast [author])),
                Emotion.UNAMUSED
            ));
        }
    }

    override public function checkFormat(args: Array<String>): Bool {
        return super.checkFormat(args) && context.message.mentions.users.size > 0;
    }
}
