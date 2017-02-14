package yliasdiscordbothx.model;

import discordbothx.log.Logger;
import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.translations.LangCenter;
import yliasdiscordbothx.utils.Humanify;
import yliasdiscordbothx.config.Config;
import yliasdiscordbothx.net.MangaPictureProxy;
import yliasdiscordbothx.model.entity.TagBlacklist;
import yliasdiscordbothx.utils.DiscordUtils;

class MangaPicture {
    private var proxy: MangaPictureProxy;
    private var context: CommunicationContext;
    private var blacklistedTags: Array<String>;
    private var maxRetries: Int;

    public function new(context: CommunicationContext, infos: MangaPictureProxyInfo) {
        proxy = new MangaPictureProxy(context, infos);
        this.context = context;
    }

    public function searchPicture(tags: Array<String>) {
        var idServer = DiscordUtils.getServerIdFromMessage(context.message);
        var author = context.message.author;

        tags = tags.filter(function(n: String) {
            return n != null && n.length > 0;
        });

        TagBlacklist.getAllForServer(idServer, function (err: Dynamic, foundBlacklistedTags: Array<String>) {
            if (err != null) {
                Logger.exception(err);
                context.sendToChannel(LangCenter.instance.translate(idServer, 'sql_error', cast [author]));
            } else {
                blacklistedTags = foundBlacklistedTags;

                var forbiddenTags = tags.filter(function(n: String) {
                    return blacklistedTags.indexOf(n.toLowerCase()) > -1;
                });

                if (forbiddenTags.length > 0) {
                    var location = DiscordUtils.getLocationStringFromMessage(context.message);

                    context.sendToOwner(LangCenter.instance.translate(idServer, 'forbidden_search_message_to_owner', cast [cast author, forbiddenTags.join(', '), location]));
                    context.sendToChannel(LangCenter.instance.translate(idServer, 'forbidden_search_public_message', cast [cast author, forbiddenTags.join(', ')]));

                    tags = tags.filter(function(n) {
                        return blacklistedTags.indexOf(n) < 0;
                    });
                }

                context.sendToChannel(LangCenter.instance.translate(idServer, 'wait', cast [cast author, cast proxy.infos.host]));

                proxy.initialize(tags, function (nbPosts: Int) {
                    if (nbPosts > 0) {
                        maxRetries = cast Math.min(nbPosts, Config.PROXY_MAX_RETRIES);
                        proxy.findPicture(proxyPictureFoundHandler);
                    }
                });
            }
        });
    }

    private function proxyPictureFoundHandler(tags: Array<String>, fileUrl:String, nsfw: Bool): Void {
        var idServer = DiscordUtils.getServerIdFromMessage(context.message);
        var author = context.message.author;

        var forbiddenTags = tags.filter(function(n: String) {
            return blacklistedTags.indexOf(n.toLowerCase()) > -1;
        });

        if (forbiddenTags.length > 0) {
            Logger.warning('Found furry picture with forbidden tags: ' + forbiddenTags.join(' '));

            if (maxRetries > 0) {
                maxRetries--;
                Logger.info('Trying to find another picture...');
                proxy.findPicture(proxyPictureFoundHandler);
            } else {
                Logger.info('No more retries, giving up.');
                context.sendToChannel(LangCenter.instance.translate(idServer, 'no_valid_picture_found', cast [author]));
            }
        } else {
            var message = author + ', ' + LangCenter.instance.translate(idServer, Humanify.getMultimediaContentDeliverySentence());

            if (fileUrl.indexOf('http') != 0) {
                if (proxy.infos.secured) {
                    fileUrl = 'https:' + fileUrl;
                } else {
                    fileUrl = 'http:' + fileUrl;
                }
            }

            if (nsfw) {
                message += '\n\nNSFW';
            }

            context.sendFileToChannel(fileUrl, 'picture.jpg', message);
        }
    }
}