package model;

import utils.Logger;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import StringTools;
import StringTools;
import external.discord.message.Message;
import external.htmlentities.Html5Entities;
import external.cleverbotnode.Cleverbot;

class Chat {
    public static var instance(get, null): Chat;

    private static var _instance: Chat;

    private var _ready: Bool;
    private var _cleverbot: Cleverbot;
    private var _html5Entities: Html5Entities;

    public static function initialize(): Void {
        if (_instance == null) {
            _instance = new Chat();
        }
    }

    public static function get_instance(): Chat {
        initialize();

        return _instance;
    }

    public function ask(msg: Message) {
        var client: Client = cast NodeJS.global.client;

        if (_ready) {
            var content = StringTools.trim(
                StringTools.replace(
                    msg.content,
                    client.user.mention(),
                    ''
                )
            );

            _cleverbot.write(content, function (response: Dynamic) {
                var output: String = '';

                if (!msg.channel.isPrivate) {
                    output = msg.author + ' => ';
                }

                output += _html5Entities.decode(response.message);

                client.sendMessage(msg.channel, output);
            });
        } else {
            client.sendMessage(msg.channel, L.a.n.g('model.chat.ask.not_ready', cast [msg.author]));
        }
    }

    private function new(): Void {
        _ready = false;
        _cleverbot = new Cleverbot();
        _html5Entities = new Html5Entities();

        Cleverbot.prepare(cleverbotPrepareHandler);
    }

    private function cleverbotPrepareHandler(): Void {
        _ready = true;
    }
}
