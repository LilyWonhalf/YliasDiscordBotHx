package yliasdiscordbothx.event;

import discordhx.channel.TextChannel;
import discordbothx.service.DiscordUtils;
import discordhx.message.Message;
import discordhx.RichEmbed;
import discordhx.invite.Invite;
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
        eventEmitter.on(cast ClientEvent.MESSAGE, messageHandler);
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

    private function messageHandler(message: Message): Void {
        var context: CommunicationContext = new CommunicationContext();
        var botOwnerId: String = Bot.instance.authDetails.BOT_OWNER_ID;

        if (message.guild != null && message.author.id != botOwnerId) {
            var botOwner: User = eventEmitter.users.get(botOwnerId);
            var channel: TextChannel = cast message.channel;
            var searching: Array<String> = [
                botOwnerId,
                botOwner.username,
            ];
            var additionalPingWords = [ // Missy forced me, I'm sorry :(
                'lilee',
                'lil',
                'liily'
            ];

            searching = searching.concat(botOwner.username.split(' ')).map(function (value: String): String {
                return value.toLowerCase();
            });

            var found = false;

            for (search in searching) {
                found = found || message.content.toLowerCase().indexOf(search) > -1;
            }

            if (found) {
                var embed: RichEmbed = new RichEmbed();

                embed.setAuthor(message.author.username, message.author.displayAvatarURL);
                embed.setDescription(message.content + '\n\n' + '[Go to message](' + untyped __js__('message.url') + ')');
                embed.setColor(Std.parseInt('0xF44336'));
                embed.setFooter('#' + channel.name + ' in ' + message.guild.name);

                context.sendEmbedToOwner(embed).catchError(Logger.exception);
            }
        }
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
                var username: String = user.username + '#' + user.discriminator + ' (ID: ' + user.id + ')';
                var embed: RichEmbed = new RichEmbed();

                embed.setAuthor(guild.name, guild.iconURL);
                embed.setThumbnail(member.user.displayAvatarURL);
                embed.setDescription(
                    LangCenter.instance.translate(
                        guild.id,
                        'notification_to_staff',
                        cast [username, guild.name]
                    )
                );
                embed.setColor(Std.parseInt('0x4CAF50'));

                for (staff in staffToNotify) {
                    context.sendEmbedTo(
                        DiscordBot.instance.client.users.get(staff.idUser),
                        embed
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
                var username: String = user.username + '#' + user.discriminator + ' (ID: ' + user.id + ')';
                var embed: RichEmbed = new RichEmbed();

                embed.setAuthor(guild.name, guild.iconURL);
                embed.setThumbnail(member.user.displayAvatarURL);
                embed.setDescription(
                    LangCenter.instance.translate(
                        guild.id,
                        'notification_to_staff',
                        cast [username, guild.name]
                    )
                );
                embed.setColor(Std.parseInt('0xF44336'));

                for (staff in staffToNotify) {
                    context.sendEmbedTo(
                        DiscordBot.instance.client.users.get(staff.idUser),
                        embed
                    );
                }
            }
        });
    }
}
