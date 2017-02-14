package yliasdiscordbothx.net;

import yliasdiscordbothx.utils.DiscordUtils;
import yliasdiscordbothx.translations.LangCenter;
import discordbothx.log.Logger;
import discordbothx.core.CommunicationContext;
import haxe.Json;
import nodejs.http.HTTP.HTTPMethod;
import js.html.Element;
import js.html.HTMLCollection;
import yliasdiscordbothx.utils.HttpUtils;
import yliasdiscordbothx.external.xmldom.DOMParser;

class MangaPictureProxy {
    public var infos: MangaPictureProxyInfo;

    private var context: CommunicationContext;
    private var tags: Array<String>;
    private var path: String;
    private var initializationCallback: Int->Void;
    private var nbPosts: Int;
    private var nbPostsByPage: Int;

    public function new(context: CommunicationContext, infos: MangaPictureProxyInfo) {
        this.infos = infos;

        this.context = context;
        tags = new Array<String>();
    }

    public function initialize(providedTags: Array<String>, callback: Int->Void): Void {
        var separator = '?';

        if (infos.pathToPosts.indexOf('?') > -1) {
            separator = '&';
        }

        tags = providedTags;
        initializationCallback = callback;
        path = infos.pathToPosts;

        if (infos.limitKey != null) {
             path += separator + infos.limitKey + '=1';
            separator = '&';
        }

        if (tags.length > 0) {
            path += separator + infos.tagsKey + '=' + tags.join(',');
        }

        HttpUtils.query(infos.secured, infos.host, path, cast HTTPMethod.Get, initializeQueryCompleteHandler);
    }

    public function findPicture(callback: Array<String>->String->Bool->Void): Void {
        var newPath = path + '&' + infos.pageKey + '=';
        var maxPage = Math.ceil(nbPosts / nbPostsByPage);
        var author = context.message.author;
        var idServer = DiscordUtils.getServerIdFromMessage(context.message);

        HttpUtils.query(infos.secured, infos.host, newPath + Math.round(Math.random() * maxPage), cast HTTPMethod.Get, function (data) {
            if (infos.isJson) {
                var jsonData: Dynamic = null;

                try {
                    jsonData = cast Json.parse(data);
                } catch (e: Dynamic) {
                    Logger.exception(e);
                }

                if (jsonData != null) {
                    var posts: Array<Dynamic> = cast Reflect.field(jsonData, infos.postsField);

                    if (posts.length > 0) {
                        var post: Dynamic = cast posts[0];
                        var tags:Array<String> = cast Reflect.field(post, infos.tagsField).split(infos.tagsSeparator);
                        var fileUrl: String = cast Reflect.field(post, infos.fileUrlField);
                        var nsfw: Bool = false;

                        if (infos.ratingField != null) {
                            nsfw = Reflect.field(post, infos.ratingField) == 'e';
                        }

                        callback(tags, fileUrl, nsfw);
                    } else {
                        Logger.error('Failed to load a picture (step 5), URL: ' + path);
                        context.sendToChannel(LangCenter.instance.translate(idServer, 'host_crashed', cast [infos.host, cast author]));
                    }
                } else {
                    Logger.error('Failed to load a picture (step 4), URL: ' + path);
                    context.sendToChannel(LangCenter.instance.translate(idServer, 'host_crashed', cast [infos.host, cast author]));
                }
            } else {
                var parser: DOMParser = new DOMParser();
                var xmlDoc = parser.parseFromString(data, 'text/xml');

                if (xmlDoc != null) {
                    var posts = xmlDoc.getElementsByTagName(infos.postField);

                    if (posts.length > 0) {
                        var post: Element = posts[0];
                        var tags:Array<String>;
                        var fileUrl: String;
                        var nsfw: Bool = false;

                        if (infos.postDataInAttributes) {
                            tags = post.getAttribute(infos.tagsField).split(infos.tagsSeparator);
                            fileUrl = post.getAttribute(infos.fileUrlField);

                            if (infos.ratingField != null) {
                                nsfw = post.getAttribute(infos.ratingField) == 'e';
                            }
                        } else {
                            tags = post.getElementsByTagName(infos.tagsField)[0].childNodes[0].nodeValue.split(infos.tagsSeparator);
                            fileUrl = post.getElementsByTagName(infos.fileUrlField)[0].childNodes[0].nodeValue;

                            if (infos.ratingField != null) {
                                nsfw = post.getElementsByTagName(infos.ratingField)[0].childNodes[0].nodeValue == 'e';
                            }
                        }

                        callback(tags, fileUrl, nsfw);
                    } else {
                        Logger.error('Failed to load a picture (step 5), URL: ' + path);
                        context.sendToChannel(LangCenter.instance.translate(idServer, 'host_crashed', cast [infos.host, cast author]));
                    }
                } else {
                    Logger.error('Failed to load a picture (step 4), URL: ' + path);
                    context.sendToChannel(LangCenter.instance.translate(idServer, 'host_crashed', cast [infos.host, cast author]));
                }
            }
        });
    }

    private function initializeQueryCompleteHandler(data: String): Void {
        var author = context.message.author;
        var idServer = DiscordUtils.getServerIdFromMessage(context.message);

        if (infos.isJson) {
            var jsonData: Dynamic = null;

            try {
                jsonData = cast Json.parse(data);
            } catch (e: Dynamic) {
                Logger.exception(e);
            }

            if (jsonData != null) {
                var posts: Array<Dynamic> = cast Reflect.field(jsonData, infos.postsField);
                nbPosts = cast Reflect.field(jsonData, infos.nbPostsField);

                if (posts.length > 0) {
                    if (nbPosts > 0) {
                        nbPostsByPage = posts.length;
                        initializationCallback(nbPosts);
                    } else {
                        Logger.error('Failed to load a picture (step 3), URL: ' + path);
                        context.sendToChannel(LangCenter.instance.translate(idServer, 'no_result', cast [infos.host, cast author]));
                        initializationCallback(nbPosts);
                    }
                } else {
                    Logger.error('Failed to load a picture (step 2), URL: ' + path);
                    context.sendToChannel(LangCenter.instance.translate(idServer, 'no_result', cast [infos.host, cast author]));
                }
            } else {
                Logger.error('Failed to load a picture (step 1), URL: ' + path);
                context.sendToChannel(LangCenter.instance.translate(idServer, 'host_crashed', cast [infos.host, cast author]));
            }
        } else {
            var parser: DOMParser = new DOMParser();
            var xmlDoc = parser.parseFromString(data, 'text/xml');

            if (xmlDoc != null) {
                var postsTags: Array<Element> = cast xmlDoc.getElementsByTagName(infos.postsField);

                if (postsTags.length > 0) {
                    nbPosts = Std.int(cast postsTags[0].getAttribute(infos.nbPostsField));

                    if (nbPosts > 0) {
                        nbPostsByPage = postsTags[0].getElementsByTagName(infos.postField).length;
                        initializationCallback(nbPosts);
                    } else {
                        Logger.error('Failed to load a picture (step 3), URL: ' + path);
                        context.sendToChannel(LangCenter.instance.translate(idServer, 'no_result', cast [infos.host, cast author]));
                        initializationCallback(nbPosts);
                    }
                } else {
                    Logger.error('Failed to load a picture (step 2), URL: ' + path);
                    context.sendToChannel(LangCenter.instance.translate(idServer, 'host_crashed', cast [infos.host, cast author]));
                }
            } else {
                Logger.error('Failed to load a picture (step 1), URL: ' + path);
                context.sendToChannel(LangCenter.instance.translate(idServer, 'host_crashed', cast [infos.host, cast author]));
            }
        }
    }
}

typedef MangaPictureProxyInfo = {
    secured: Bool,
    host: String,
    limitKey: String,
    tagsKey: String,
    tagsKeySeparator: String,
    pageKey: String,
    pathToPosts: String,
    isJson: Bool,
    postDataInAttributes: Bool,
    nbPostsField: String,
    postsField: String,
    postField: String,
    tagsField: String,
    fileUrlField: String,
    ratingField: String,
    tagsSeparator: String
}
