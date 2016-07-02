package net;

import model.CommunicationContext;
import haxe.Json;
import js.html.Text;
import nodejs.http.HTTP.HTTPMethod;
import js.html.Element;
import js.html.HTMLCollection;
import translations.LangCenter;
import discordhx.message.Message;
import nodejs.NodeJS;
import discordhx.client.Client;
import utils.Logger;
import utils.HttpUtils;
import external.xmldom.DOMParser;

class MangaPictureProxy {
    public var infos: MangaPictureProxyInfo;

    private var _context: CommunicationContext;
    private var _tags: Array<String>;
    private var _path: String;
    private var _initializationCallback: Int->Void;
    private var _nbPosts: Int;
    private var _nbPostsByPage: Int;

    public function new(context: CommunicationContext, infos: MangaPictureProxyInfo) {
        this.infos = infos;

        _context = context;
        _tags = new Array<String>();
    }

    public function initialize(tags: Array<String>, callback: Int->Void): Void {
        var separator = '?';

        if (infos.pathToPosts.indexOf('?') > -1) {
            separator = '&';
        }

        _tags = tags;
        _initializationCallback = callback;
        _path = infos.pathToPosts;

        if (infos.limitKey != null) {
             _path += separator + infos.limitKey + '=1';
            separator = '&';
        }

        if (_tags.length > 0) {
            _path += separator + infos.tagsKey + '=' + _tags.join(',');
        }

        HttpUtils.query(infos.secured, infos.host, _path, cast HTTPMethod.Get, initializeQueryCompleteHandler);
    }

    public function findPicture(callback: Array<String>->String->Bool->Void): Void {
        var newPath = _path + '&' + infos.pageKey + '=';
        var maxPage = Math.ceil(_nbPosts / _nbPostsByPage);
        var author = _context.getMessage().author;

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
                        Logger.error('Failed to load a picture (step 5), URL: ' + _path);
                        _context.sendToChannel('net.mangapictureproxy.initializequerycompletehandler.host_crashed', cast [infos.host, cast author]);
                    }
                } else {
                    Logger.error('Failed to load a picture (step 4), URL: ' + _path);
                    _context.sendToChannel('net.mangapictureproxy.initializequerycompletehandler.host_crashed', cast [infos.host, cast author]);
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
                        Logger.error('Failed to load a picture (step 5), URL: ' + _path);
                        _context.sendToChannel('net.mangapictureproxy.initializequerycompletehandler.host_crashed', cast [infos.host, cast author]);
                    }
                } else {
                    Logger.error('Failed to load a picture (step 4), URL: ' + _path);
                    _context.sendToChannel('net.mangapictureproxy.initializequerycompletehandler.host_crashed', cast [infos.host, cast author]);
                }
            }
        });
    }

    private function initializeQueryCompleteHandler(data: String): Void {
        var author = _context.getMessage().author;

        if (infos.isJson) {
            var jsonData: Dynamic = null;

            try {
                jsonData = cast Json.parse(data);
            } catch (e: Dynamic) {
                Logger.exception(e);
            }

            if (jsonData != null) {
                var posts: Array<Dynamic> = cast Reflect.field(jsonData, infos.postsField);
                _nbPosts = cast Reflect.field(jsonData, infos.nbPostsField);

                if (posts.length > 0) {
                    if (_nbPosts > 0) {
                        _nbPostsByPage = posts.length;
                        _initializationCallback(_nbPosts);
                    } else {
                        Logger.error('Failed to load a picture (step 3), URL: ' + _path);
                        _context.sendToChannel('net.mangapictureproxy.initializequerycompletehandler.no_result', cast [infos.host, cast author]);
                        _initializationCallback(_nbPosts);
                    }
                } else {
                    Logger.error('Failed to load a picture (step 2), URL: ' + _path);
                    _context.sendToChannel('net.mangapictureproxy.initializequerycompletehandler.no_result', cast [infos.host, cast author]);
                }
            } else {
                Logger.error('Failed to load a picture (step 1), URL: ' + _path);
                _context.sendToChannel('net.mangapictureproxy.initializequerycompletehandler.host_crashed', cast [infos.host, cast author]);
            }
        } else {
            var parser: DOMParser = new DOMParser();
            var xmlDoc = parser.parseFromString(data, 'text/xml');

            if (xmlDoc != null) {
                var postsTags: Array<Element> = cast xmlDoc.getElementsByTagName(infos.postsField);

                if (postsTags.length > 0) {
                    _nbPosts = Std.int(cast postsTags[0].getAttribute(infos.nbPostsField));

                    if (_nbPosts > 0) {
                        _nbPostsByPage = postsTags[0].getElementsByTagName(infos.postField).length;
                        _initializationCallback(_nbPosts);
                    } else {
                        Logger.error('Failed to load a picture (step 3), URL: ' + _path);
                        _context.sendToChannel('net.mangapictureproxy.initializequerycompletehandler.no_result', cast [infos.host, cast author]);
                        _initializationCallback(_nbPosts);
                    }
                } else {
                    Logger.error('Failed to load a picture (step 2), URL: ' + _path);
                    _context.sendToChannel('net.mangapictureproxy.initializequerycompletehandler.host_crashed', cast [infos.host, cast author]);
                }
            } else {
                Logger.error('Failed to load a picture (step 1), URL: ' + _path);
                _context.sendToChannel('net.mangapictureproxy.initializequerycompletehandler.host_crashed', cast [infos.host, cast author]);
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
