package utils;

import model.Core;
import translations.LangCenter;
import discordhx.channel.TextChannel;
import config.Config;
import discordhx.message.Message;
import discordhx.channel.PMChannel;
import config.AuthDetails;
import discordhx.user.User;

class DiscordUtils {
    public static function getOwnerInstance(): User {
        return Core.instance.getPrivateChannels().filter(
            function(e: PMChannel) {
                return e.recipient.id == AuthDetails.OWNER_ID;
            }
        )[0].recipient;
    }

    public static function isHightlight(str: String): Bool {
        return ~/<@!?\d+>/ig.match(str);
    }

    public static function getIdFromHighlight(str: String): String {
        return ~/[^\d]+/ig.replace(str, '');
    }

    public static function getUserFromSearch(userList: Array<User>, search: String): User {
        var searches = search.split(' ');
        var highlight = isHightlight(search);
        var userId: String = null;
        var userName: String = null;
        var userInstance: User = null;
        var i = 0;
        var j = 0;

        if (highlight) {
            userId = getIdFromHighlight(search);
        }

        while (i < userList.length && (userId == null || userName == null)) {
            if (highlight) {
                if (userList[i].id == userId) {
                    userName = userList[i].username;
                    userInstance = userList[i];
                }
            } else {
                while (j < searches.length && userId == null) {
                    if (userList[i].username.toLowerCase().indexOf(searches[j].toLowerCase()) > -1) {
                        userId = userList[i].id;
                        userName = userList[i].username;
                        userInstance = userList[i];
                    }

                    j++;
                }
            }

            j = 0;
            i++;
        }

        return userInstance;
    }

    public static function isMentionned(mentions: Array<User>, User): Bool {
        return mentions.indexOf(User) > -1;
    }

    public static function getServerIdFromMessage(msg: Message): String {
        var idServer: String = Config.KEY_ALL;

        if (!msg.channel.isPrivate) {
            var channel: TextChannel = cast msg.channel;
            idServer = channel.server.id;
        }

        return idServer;
    }

    public static function getLocationStringFromMessage(msg: Message): String {
        var location: String;

        if (msg.channel.isPrivate) {
            location = LangCenter.instance.translate(
                Config.KEY_ALL,
                'utils.discordutils.getlocationstringfrommessage.location_private',
                [
                    Date.now().toString()
                ]
            );
        } else {
            var channel: TextChannel = cast msg.channel;

            location = LangCenter.instance.translate(
                channel.server.id,
                'utils.discordutils.getlocationstringfrommessage.location_public',
                [
                    channel.server.name,
                    channel.name,
                    Date.now().toString()
                ]
            );
        }

        return location;
    }

    public static function splitLongMessage(content: String): Array<String> {
        var splittedMessage = new Array<String>();

        if (content.length > Config.MESSAGE_MAX_LENGTH) {
            while (content.length > 0) {
                var chunck = content.substr(0, Config.MESSAGE_MAX_LENGTH);
                var splitPosition = chunck.lastIndexOf('\n');

                if (splitPosition < 0) {
                    splittedMessage.push(chunck.substr(0, Config.MESSAGE_MAX_LENGTH));
                    content = content.substr(Config.MESSAGE_MAX_LENGTH);
                } else {
                    splittedMessage.push(chunck.substr(0, splitPosition));
                    content = content.substr(splitPosition + 1);
                }
            }
        } else {
            splittedMessage.push(content);
        }

        return splittedMessage;
    }
}
