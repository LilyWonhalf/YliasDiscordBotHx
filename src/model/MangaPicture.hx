package model;

import utils.Humanify;
import config.Config;
import net.MangaPictureProxy;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import utils.Logger;
import model.entity.TagBlacklist;
import utils.DiscordUtils;
import external.discord.message.Message;

class MangaPicture {
    private var _proxy: MangaPictureProxy;
    private var _msg: Message;
    private var _blacklistedTags: Array<String>;
    private var _maxRetries: Int;

    public function new(msg: Message, infos: MangaPictureProxyInfo) {
        _proxy = new MangaPictureProxy(msg, infos);
        _msg = msg;
    }

    public function searchPicture(tags: Array<String>) {
        var client: Client = cast NodeJS.global.client;
        var idServer = DiscordUtils.getServerIdFromMessage(_msg);

        TagBlacklist.getAll(idServer, function (err: Dynamic, blacklistedTags: Array<String>) {
            if (err != null) {
                Logger.exception(err);
                client.sendMessage(_msg.channel, L.a.n.g('model.mangapicture.searchpicture.sql_error', cast [_msg.author]));
            } else {
                _blacklistedTags = blacklistedTags;

                var forbiddenTags = tags.filter(function(n: String) {
                    return _blacklistedTags.indexOf(n.toLowerCase()) > -1;
                });

                if (forbiddenTags.length > 0) {
                    var location = DiscordUtils.getLocationStringFromMessage(_msg);

                    DiscordUtils.sendMessageToOwner(L.a.n.g('model.mangapicture.searchpicture.forbidden_search_message_to_owner', cast [cast _msg.author, forbiddenTags.join(', ')]) + ' ' + location);
                    client.sendMessage(_msg.channel, L.a.n.g('model.mangapicture.searchpicture.forbidden_search_public_message', cast [cast _msg.author, forbiddenTags.join(', ')]));

                    tags = tags.filter(function(n) {
                        return _blacklistedTags.indexOf(n) < 0;
                    });
                }

                client.sendMessage(_msg.channel, L.a.n.g('model.mangapicture.searchpicture.wait', cast [cast _msg.author, cast _proxy.infos.host]));
                _proxy.initialize(tags, function (nbPosts: Int) {
                    if (nbPosts > 0) {
                        _maxRetries = cast Math.min(nbPosts, Config.PROXY_MAX_RETRIES);
                        _proxy.findPicture(proxyPictureFoundHandler);
                    }
                });
            }
        });
    }

    private function proxyPictureFoundHandler(tags: Array<String>, fileUrl:String, nsfw: Bool): Void {
        var forbiddenTags = tags.filter(function(n: String) {
            return _blacklistedTags.indexOf(n.toLowerCase()) > -1;
        });

        if (forbiddenTags.length > 0) {
            Logger.warning('Found furry picture with forbidden tags: ' + forbiddenTags.join(' '));

            if (_maxRetries > 0) {
                _maxRetries--;
                Logger.info('Trying to find another picture...');
                _proxy.findPicture(proxyPictureFoundHandler);
            } else {
                var client: Client = cast NodeJS.global.client;

                Logger.info('No more retries, giving up.');
                client.sendMessage(_msg.channel, L.a.n.g('model.mangapicture.proxypicturefoundhandler.no_valid_picture_found', cast [_msg.author]));
            }
        } else {
            var client: Client = cast NodeJS.global.client;
            var message = Humanify.getMultimediaContentDeliverySentence();

            if (fileUrl.indexOf('http') != 0) {
                if (_proxy.infos.secured) {
                    fileUrl = 'https:' + fileUrl;
                } else {
                    fileUrl = 'http:' + fileUrl;
                }
            }

            if (nsfw) {
                message += '\n\nNSFW';
            }

            client.sendMessage(_msg.channel, _msg.author + ' => ' + message, cast {tts: false}, function(err: Dynamic, msg: Message) {
                client.sendMessage(_msg.channel, _msg.author + ' => ' + fileUrl);
            });
        }
    }
}

enum MangaPictureHost {
    e621;
    e926;
    gelbooru;
    safebooru;
}
