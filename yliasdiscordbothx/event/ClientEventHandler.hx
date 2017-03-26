package yliasdiscordbothx.event;

import discordhx.invite.Invite;
import yliasdiscordbothx.config.Config;
import discordhx.guild.Guild;
import discordhx.guild.GuildMember;
import yliasdiscordbothx.model.Db;
import discordbothx.core.DiscordBot;
import yliasdiscordbothx.model.entity.Staff;
import yliasdiscordbothx.translations.LangCenter;
import yliasdiscordbothx.model.entity.WelcomeMessage;
import discordbothx.core.CommunicationContext;
import discordhx.user.User;
import yliasdiscordbothx.model.entity.User as UserEntity;
import yliasdiscordbothx.model.entity.Channel;
import yliasdiscordbothx.model.entity.Server;
import discordbothx.log.Logger;
import discordhx.client.Client;

class ClientEventHandler extends EventHandler<Client> {
    private override function process(): Void {
        eventEmitter.on(cast ClientEvent.READY, readyHandler);
        eventEmitter.on(cast ClientEvent.GUILD_CREATE, registerEntities);
        eventEmitter.on(cast ClientEvent.CHANNEL_CREATE, registerEntities);
        eventEmitter.on(cast ClientEvent.GUILD_MEMBER_ADD, serverNewMemberHandler);
        eventEmitter.on(cast ClientEvent.GUILD_MEMBER_REMOVE, serverMemberRemovedHandler);
    }

    private function readyHandler(): Void {
        Db.instance;
        LangCenter.instance;

        registerEntities();
    }

    private function registerEntities(): Void {
        Server.registerServers();
        Channel.registerChannels();
        UserEntity.registerUsers();
    }

    private function guildCreateHandler(guild: Guild): Void {
        var context: CommunicationContext = new CommunicationContext();
        var owner: User = guild.owner.user;

        context.sendToOwner('J\'ai été invité sur un nouveau serveur nommé **' + guild.name + '**. Le créateur, c\'est **' + owner.username + '#' + owner.discriminator + '**.');

        if (!guild.members.has(Bot.instance.authDetails.BOT_OWNER_ID)) {
            guild.defaultChannel.createInvite(cast {temporary: false, maxUses: 1}).then(function (invite: Invite) {
                context.sendToOwner('Voici une invitation : ' + invite.url);
            }).catchError(function (error: Dynamic) {
                context.sendToOwner('Je n\'ai pas pu créer d\'invitation...\n\n```' + error + '```');
            });
        }
    }

    private function serverNewMemberHandler(member: GuildMember): Void {
        Logger.info('New member joined!');
        registerEntities();

        var context: CommunicationContext = new CommunicationContext();
        var guild: Guild = member.guild;
        var user: User = member.user;

        WelcomeMessage.getForServer(guild.id, function(err: Dynamic, message: String) {
            if (err != null) {
                Logger.exception(err);
                context.sendToOwner(LangCenter.instance.translate(guild.id, 'fail', cast [user.username, guild.name]));
            } else {
                if (message != null) {
                    context.sendTo(user, message);
                }
            }
        });

        Staff.getStaffToNotifyAboutNewMember(guild.id, function (staffToNotify: Array<Staff>): Void {
            if (staffToNotify != null && staffToNotify.length > 0) {
                for (staff in staffToNotify) {
                    context.sendTo(
                        DiscordBot.instance.client.users.get(staff.idUser),
                        LangCenter.instance.translate(guild.id, 'notification_to_staff', cast [user.username, guild.name])
                    );
                }
            }
        });
    }

    private function serverMemberRemovedHandler(member: GuildMember): Void {
        Logger.info('Member removed!');

        var context: CommunicationContext = new CommunicationContext();
        var guild: Guild = member.guild;
        var user: User = member.user;

        Staff.getStaffToNotifyAboutNewMember(guild.id, function (staffToNotify: Array<Staff>): Void {
            if (staffToNotify != null && staffToNotify.length > 0) {
                for (staff in staffToNotify) {
                    context.sendTo(
                        DiscordBot.instance.client.users.get(staff.idUser),
                        LangCenter.instance.translate(guild.id, 'notification_to_staff', cast [user.username, guild.name])
                    );
                }
            }
        });
    }
}
