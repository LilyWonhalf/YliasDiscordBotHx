package model;

import translations.LangCenter;
import utils.Humanify;
import config.Config;
import net.MangaPictureProxy;
import translations.LangCenter;
import utils.Logger;
import model.entity.TagBlacklist;
import utils.DiscordUtils;
import discordhx.message.Message;

class MangaPicture {
    private var _proxy: MangaPictureProxy;
    private var _context: CommunicationContext;
    private var _blacklistedTags: Array<String>;
    private var _maxRetries: Int;

    public function new(context: CommunicationContext, infos: MangaPictureProxyInfo) {
        _proxy = new MangaPictureProxy(context, infos);
        _context = context;
    }

    public function searchPicture(tags: Array<String>) {
        var idServer = DiscordUtils.getServerIdFromMessage(_context.getMessage());
        var author = _context.getMessage().author;

        tags = tags.filter(function(n: String) {
            return n != null && n.length > 0;
        });

        TagBlacklist.getAllForServer(idServer, function (err: Dynamic, blacklistedTags: Array<String>) {
            if (err != null) {
                Logger.exception(err);
                _context.sendToChannel('model.mangapicture.searchpicture.sql_error', cast [author]);
            } else {
                _blacklistedTags = blacklistedTags;

                var forbiddenTags = tags.filter(function(n: String) {
                    return _blacklistedTags.indexOf(n.toLowerCase()) > -1;
                });

                if (forbiddenTags.length > 0) {
                    var location = DiscordUtils.getLocationStringFromMessage(_context.getMessage());

                    _context.sendToOwner('model.mangapicture.searchpicture.forbidden_search_message_to_owner', cast [cast author, forbiddenTags.join(', '), location]);
                    _context.sendToChannel('model.mangapicture.searchpicture.forbidden_search_public_message', cast [cast author, forbiddenTags.join(', ')]);

                    tags = tags.filter(function(n) {
                        return _blacklistedTags.indexOf(n) < 0;
                    });
                }

                _context.sendToChannel('model.mangapicture.searchpicture.wait', cast [cast author, cast _proxy.infos.host]);

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
        var author = _context.getMessage().author;

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
                Logger.info('No more retries, giving up.');
                _context.sendToChannel('model.mangapicture.proxypicturefoundhandler.no_valid_picture_found', cast [author]);
            }
        } else {
            var idServer = DiscordUtils.getServerIdFromMessage(_context.getMessage());
            var message = LangCenter.instance.translate(idServer, Humanify.getMultimediaContentDeliverySentence());

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

            message += '\n\n' + fileUrl;

            _context.rawSendToChannel(author + ' => ' + message);
        }
    }
}