package yliasdiscordbothx.utils;

import discordhx.channel.DMChannel;
import discordhx.channel.GroupDMChannel;
import discordhx.channel.ChannelType;
import discordhx.channel.Channel;
import discordhx.channel.TextChannel;
import yliasdiscordbothx.translations.LangCenter;
import yliasdiscordbothx.config.Config;
import discordhx.message.Message;

class DiscordUtils {
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

    public static function isHightlight(str: String): Bool {
        return ~/<@!?\d+>/ig.match(str);
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
}
