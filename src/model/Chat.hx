package model;

import discordhx.user.User;
import utils.Logger;
import translations.LangCenter;
import nodejs.NodeJS;
import discordhx.client.Client;
import StringTools;
import StringTools;
import discordhx.message.Message;
import external.htmlentities.Html5Entities;
import external.cleverbotnode.Cleverbot;

class Chat {
    private static inline var MAX_FAST_ANSWER_DELAY = 1500; // In milliseconds
    private static inline var MAX_FAST_ANSWER_AMOUNT = 3; // In milliseconds

    public static var instance(get, null): Chat;

    private static var _instance: Chat;

    private var _ready: Bool;
    private var _cleverbot: Cleverbot;
    private var _html5Entities: Html5Entities;

    // Bot answer loop handling
    private var _lastAnswerTimestamp: Map<String, Date>;
    private var _nbFastAnswersLeft: Map<String, Int>;

    public static function initialize(): Void {
        if (_instance == null) {
            _instance = new Chat();
        }
    }

    public static function get_instance(): Chat {
        initialize();

        return _instance;
    }

    public function ask(context: CommunicationContext) {
        var user: User = Core.userInstance;
        var msg: Message = context.getMessage();
        var msgTimestamp: Date = Date.now();
        var answer: Bool = true;
        var fastAnswersLeft: Int;

        if (!_nbFastAnswersLeft.exists(msg.author.id)) {
            _nbFastAnswersLeft.set(msg.author.id, MAX_FAST_ANSWER_AMOUNT);
        }

        fastAnswersLeft = _nbFastAnswersLeft.get(msg.author.id);

        if (_ready) {
            if (_lastAnswerTimestamp.exists(msg.author.id)) {
                if (msgTimestamp.getTime() - _lastAnswerTimestamp.get(msg.author.id).getTime() <= MAX_FAST_ANSWER_DELAY) {
                    if (fastAnswersLeft < 1) {
                        answer = false;
                        _nbFastAnswersLeft.set(msg.author.id, MAX_FAST_ANSWER_AMOUNT);
                    } else {
                        _nbFastAnswersLeft.set(msg.author.id, fastAnswersLeft - 1);
                    }
                }
            }

            _lastAnswerTimestamp.set(msg.author.id, msgTimestamp);

            if (answer) {
                var content = StringTools.trim(
                    StringTools.replace(
                        msg.content,
                        user.mention(),
                        ''
                    )
                );

                _cleverbot.write(content, function (response: Dynamic) {
                    var output: String = '';

                    if (!msg.channel.isPrivate) {
                        output = msg.author + ' => ';
                    }

                    output += _html5Entities.decode(response.message);

                    context.rawSendToChannel(output);
                });
            } else {
                Logger.error('Bot suspected, not replying anymore for now');
                context.sendToChannel('model.chat.ask.bot_suspected', cast [msg.author.username]);
            }
        } else {
            Logger.error('Received direct message when not ready to answer');
            context.sendToChannel('model.chat.ask.not_ready', cast [msg.author]);
        }
    }

    private function new(): Void {
        _ready = false;
        _cleverbot = new Cleverbot();
        _html5Entities = new Html5Entities();
        _lastAnswerTimestamp = new Map<String, Date>();
        _nbFastAnswersLeft = new Map<String, Int>();

        Cleverbot.prepare(cleverbotPrepareHandler);
    }

    private function cleverbotPrepareHandler(): Void {
        _ready = true;
    }
}
