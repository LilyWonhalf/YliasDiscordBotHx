package yliasdiscordbothx.utils;

import yliasdiscordbothx.system.FileSystem;
import discordbothx.log.Logger;
import discordhx.guild.GuildMember;
import discordhx.channel.GuildChannel;
import discordhx.role.Role;
import discordbothx.core.DiscordBot;
import discordhx.Collection;
import discordhx.user.User;
import discordbothx.core.CommunicationContext;
import js.RegExp;
import discordbothx.service.DiscordUtils;
import discordhx.RichEmbed;
import yliasdiscordbothx.model.Emotion;
import discordhx.channel.DMChannel;
import discordhx.channel.GroupDMChannel;
import discordhx.channel.ChannelType;
import discordhx.channel.Channel;
import discordhx.channel.TextChannel;
import yliasdiscordbothx.translations.LangCenter;
import yliasdiscordbothx.config.Config;
import discordhx.message.Message;

class YliasDiscordUtils {
    public static function setTyping(typing: Bool, channel: Channel): Void {
        switch (channel.type) {
            case ChannelType.TEXT:
                var channel: TextChannel = cast channel;

                if (typing) {
                    channel.startTyping();
                } else {
                    channel.stopTyping(true);
                }

            case ChannelType.GROUP:
                var groupChannel: GroupDMChannel = cast channel;

                if (typing) {
                    groupChannel.startTyping();
                } else {
                    groupChannel.stopTyping(true);
                }

            default:
                var dmChannel: DMChannel = cast channel;

                if (typing) {
                    dmChannel.startTyping();
                } else {
                    dmChannel.stopTyping(true);
                }
        }
    }

    public static function isUserHightlight(str: String): Bool {
        return ~/<@!?\d+>/ig.match(str);
    }

    public static function isChannelHightlight(str: String): Bool {
        return ~/<#\d+>/ig.match(str);
    }

    public static function isRoleHightlight(str: String): Bool {
        return ~/<@&\d+>/ig.match(str);
    }

    public static function getIdFromHighlight(str: String): String {
        return ~/[^\d]+/ig.replace(str, '');
    }

    public static function getServerIdFromMessage(message: Message): String {
        var idServer: String = Config.KEY_ALL;

        if (message.guild != null) {
            idServer = message.guild.id;
        }

        return idServer;
    }

    public static function getLocationStringFromMessage(message: Message): String {
        var location: String;

        if (message.guild == null) {
            location = LangCenter.instance.translate(Config.KEY_ALL, 'location_private', [Date.now().toString()]);
        } else {
            var channel: TextChannel = cast message.channel;

            location = LangCenter.instance.translate(message.guild.id, 'location_public', [
                message.guild.name,
                channel.name,
                Date.now().toString()
            ]);
        }

        return location;
    }

    public static function getEmbeddedMessage(title: String, message: String, ?emotion: Emotion): RichEmbed {
        var embed: RichEmbed = new RichEmbed();

        embed.setTitle(title);
        embed.setDescription(message);
        embed.setColor(DiscordUtils.getMaterialUIColor());

        if (emotion != null) {
            embed.setThumbnail(Config.EMOTIONS_PATH + emotion);
        }

        return embed;
    }

    public static function getCleanString(context: CommunicationContext, str: String): String {
        var channel: Channel = cast context.message.channel;
        var userList: Collection<String, User> = null;
        var emojis: Dynamic = FileSystem.json('yliasdiscordbothx/config/emoji.json');
        var userMention: RegExp = new RegExp('<@!?([0-9]+)>');
        var roleMention: RegExp = new RegExp('<@&([0-9]+)>');
        var channelMention: RegExp = new RegExp('<#([0-9]+)>');
        var emojiMention: RegExp = new RegExp(':([^\\s:]+):');
        var userMatch: RegExpMatch = userMention.exec(str);
        var roleMatch: RegExpMatch = roleMention.exec(str);
        var channelMatch: RegExpMatch = channelMention.exec(str);
        var emojiMatch: RegExpMatch = emojiMention.exec(str);
        var notFound: Collection<String, String> = new Collection<String, String>();
        var notFoundIndex: Int = 0;

        switch (channel.type) {
            case ChannelType.TEXT:
                var memberList: Array<GuildMember> = context.message.guild.members.array();
                userList = new Collection<String, User>();

                for (member in memberList) {
                    userList.set(member.id, member.user);
                }

            case ChannelType.GROUP:
                var groupChannel: GroupDMChannel = cast channel;
                userList = groupChannel.recipients;

            default:
                var privateChannel: DMChannel = cast channel;

                userList = new Collection<String, User>();
                userList.set(DiscordBot.instance.client.user.id, DiscordBot.instance.client.user);
                userList.set(privateChannel.recipient.id, privateChannel.recipient);
        }

        while (userMatch != null) {
            var userId: String = userMatch[1];
            var found = false;

            if (userList.has(userId)) {
                var user: User = userList.get(userId);
                var username: String = user.username;

                if (channel.type == ChannelType.TEXT) {
                    var member: GuildMember = context.message.guild.member(user);

                    if (member.nickname != null) {
                        username = member.nickname;
                    }
                }

                found = true;
                str = StringTools.replace(str, userMatch[0], '@' + username);
            }

            if (!found) {
                var random: String = StringTools.hex(Math.ceil((Math.random() + 1) * 100000));
                random = 'rainbow' + random + 'dash' + notFoundIndex + 'rocks';

                str = StringTools.replace(str, userMatch[0], random);
                notFound.set(random, userMatch[0]);
                notFoundIndex++;
            }

            userMatch = userMention.exec(str);
        }

        for (key in notFound.keyArray()) {
            str = StringTools.replace(str, key, notFound.get(key));
        }

        notFound = new Collection<String, String>();

        while (roleMatch != null) {
            var roleId: String = roleMatch[1];
            var found = false;

            if (channel.type == ChannelType.TEXT) {
                var roleList: Collection<String, Role> = context.message.guild.roles;

                if (roleList.has(roleId)) {
                    found = true;
                    str = StringTools.replace(str, roleMatch[0], '@' + roleList.get(roleId).name);
                }
            }

            if (!found) {
                var random: String = StringTools.hex(Math.ceil((Math.random() + 1) * 100000));
                random = 'rainbow' + random + 'dash' + notFoundIndex + 'rocks';

                str = StringTools.replace(str, roleMatch[0], random);
                notFound.set(random, roleMatch[0]);
                notFoundIndex++;
            }

            roleMatch = roleMention.exec(str);
        }

        for (key in notFound.keyArray()) {
            str = StringTools.replace(str, key, notFound.get(key));
        }

        notFound = new Collection<String, String>();

        while (channelMatch != null) {
            var channelId: String = channelMatch[1];
            var found = false;

            if (channel.type == ChannelType.TEXT) {
                var channelList: Collection<String, GuildChannel> = context.message.guild.channels;

                if (channelList.has(channelId)) {
                    found = true;
                    str = StringTools.replace(str, channelMatch[0], '#' + channelList.get(channelId).name);
                }
            }

            if (!found) {
                var random: String = StringTools.hex(Math.ceil((Math.random() + 1) * 100000));
                random = 'rainbow' + random + 'dash' + notFoundIndex + 'rocks';

                str = StringTools.replace(str, channelMatch[0], random);
                notFound.set(random, channelMatch[0]);
                notFoundIndex++;
            }

            channelMatch = channelMention.exec(str);
        }

        for (key in notFound.keyArray()) {
            str = StringTools.replace(str, key, notFound.get(key));
        }

        notFound = new Collection<String, String>();

        while (emojiMatch != null) {
            var emoji: String = emojiMatch[1];
            var found = false;

            if (Reflect.hasField(emojis, emoji)) {
                var finalEmoji: String = '';
                var finalEmojiCharCodes: Array<Int> = cast Reflect.field(emojis, emoji);

                for (i in 0...finalEmojiCharCodes.length) {
                    finalEmoji += String.fromCharCode(finalEmojiCharCodes[i]);
                }

                found = true;
                str = StringTools.replace(str, emojiMatch[0], finalEmoji);
            }

            if (!found) {
                var random: String = StringTools.hex(Math.ceil((Math.random() + 1) * 100000));
                random = 'rainbow' + random + 'dash' + notFoundIndex + 'rocks';

                str = StringTools.replace(str, emojiMatch[0], random);
                notFound.set(random, emojiMatch[0]);
                notFoundIndex++;
            }

            emojiMatch = emojiMention.exec(str);
        }

        for (key in notFound.keyArray()) {
            str = StringTools.replace(str, key, notFound.get(key));
        }

        notFound = new Collection<String, String>();

        return str;
    }
}
