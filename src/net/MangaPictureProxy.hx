package net;

import js.html.Text;
import nodejs.http.HTTP.HTTPMethod;
import js.html.Element;
import js.html.HTMLCollection;
import translations.L;
import external.discord.message.Message;
import nodejs.NodeJS;
import external.discord.client.Client;
import utils.Logger;
import utils.HttpUtils;
import external.xmldom.DOMParser;

class MangaPictureProxy {
    public var infos: MangaPictureProxyInfo;

    private var _msg: Message;
    private var _tags: Array<String>;
    private var _path: String;
    private var _initializationCallback: Int->Void;
    private var _nbPosts: Int;

    public function new(msg: Message, infos: MangaPictureProxyInfo) {
        this.infos = infos;

        _msg = msg;
        _tags = new Array<String>();
    }

    public function initialize(tags: Array<String>, callback: Int->Void): Void {
        var separator = '?';

        if (infos.pathToPosts.indexOf('?') > -1) {
            separator = '&';
        }

        _tags = tags;
        _initializationCallback = callback;
        _path = infos.pathToPosts + separator + infos.limitKey + '=1';

        if (_tags.length > 0) {
            _path += '&' + infos.tagsKey + '=' + _tags.join(',');
        }

        HttpUtils.query(infos.secured, infos.host, _path, cast HTTPMethod.Get, initializeQueryCompleteHandler);
    }

    public function findPicture(callback: Array<String>->String->Bool->Void): Void {
        var newPath = _path + '&' + infos.pageKey + '=';

        HttpUtils.query(infos.secured, infos.host, newPath + Math.round(Math.random() * _nbPosts), cast HTTPMethod.Get, function (data) {
            var parser: DOMParser = new DOMParser();
            var xmlDoc = parser.parseFromString(data, 'text/xml');
            var client: Client = cast NodeJS.global.client;

            if (xmlDoc != null) {
                var posts = xmlDoc.getElementsByTagName('post');

                if (posts.length > 0) {
                    var post: Element = posts[0];
                    var tags:Array<String>;
                    var fileUrl: String;
                    var nsfw: Bool;

                    if (infos.postDataInAttributes) {
                        tags = post.getAttribute('tags').split(' ');
                        fileUrl = post.getAttribute('file_url');
                        nsfw = post.getAttribute('rating') == 'e';
                    } else {
                        tags = post.getElementsByTagName('tags')[0].childNodes[0].nodeValue.split(' ');
                        fileUrl = post.getElementsByTagName('file_url')[0].childNodes[0].nodeValue;
                        nsfw = post.getElementsByTagName('rating')[0].childNodes[0].nodeValue == 'e';
                    }

                    callback(tags, fileUrl, nsfw);
                } else {
                    Logger.error('Failed to load a picture (step 5), URL: ' + _path);
                    client.sendMessage(_msg.channel, L.a.n.g('net.mangapictureproxy.initializequerycompletehandler.host_crashed', cast [infos.host, cast _msg.author]));
                }
            } else {
                Logger.error('Failed to load a picture (step 4), URL: ' + _path);
                client.sendMessage(_msg.channel, L.a.n.g('net.mangapictureproxy.initializequerycompletehandler.host_crashed', cast [infos.host, cast _msg.author]));
            }
        });
    }

    private function initializeQueryCompleteHandler(data: String): Void {
        var parser: DOMParser = new DOMParser();
        var xmlDoc = parser.parseFromString(data, 'text/xml');
        var client: Client = cast NodeJS.global.client;

        if (xmlDoc != null) {
            var postsTags: Array<Element> = cast xmlDoc.getElementsByTagName('posts');

            if (postsTags.length > 0) {
                _nbPosts = Std.int(cast postsTags[0].getAttribute('count'));

                if (_nbPosts > 0) {
                    _initializationCallback(_nbPosts);
                } else {
                    Logger.error('Failed to load a picture (step 3), URL: ' + _path);
                    client.sendMessage(_msg.channel, L.a.n.g('net.mangapictureproxy.initializequerycompletehandler.no_result', cast [infos.host, cast _msg.author]));
                    _initializationCallback(_nbPosts);
                }
            } else {
                Logger.error('Failed to load a picture (step 2), URL: ' + _path);
                client.sendMessage(_msg.channel, L.a.n.g('net.mangapictureproxy.initializequerycompletehandler.host_crashed', cast [infos.host, cast _msg.author]));
            }
        } else {
            Logger.error('Failed to load a picture (step 1), URL: ' + _path);
            client.sendMessage(_msg.channel, L.a.n.g('net.mangapictureproxy.initializequerycompletehandler.host_crashed', cast [infos.host, cast _msg.author]));
        }
    }
}

typedef MangaPictureProxyInfo = {
    secured: Bool,
    host: String,
    limitKey: String,
    tagsKey: String,
    pageKey: String,
    pathToPosts: String,
    postDataInAttributes: Bool
}
