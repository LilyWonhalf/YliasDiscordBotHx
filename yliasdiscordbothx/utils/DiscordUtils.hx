package yliasdiscordbothx.utils;

import discordhx.channel.TextChannel;
import yliasdiscordbothx.translations.LangCenter;
import yliasdiscordbothx.config.Config;
import discordhx.message.Message;

class DiscordUtils {
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
