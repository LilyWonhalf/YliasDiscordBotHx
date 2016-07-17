package model;

import utils.Logger;
import discordhx.message.MessageOptions;
import discordhx.Resolvables.ChannelResolvable;
import config.Config;
import utils.DiscordUtils;
import translations.LangCenter;
import discordhx.message.Message;
import discordhx.client.Client;

class CommunicationContext {
    private static inline var MAX_RETRIES = 30;

    private var _client: Client;
    private var _msg: Message;

    // Message error handling
    private var _pool: Array<DelayedMessage>;
    private var _isBusy: Bool;
    private var _retriesLeft: Int;

    public function new(client: Client, ?msg: Message) {
        _client = client;
        _msg = msg;
        _pool = new Array<DelayedMessage>();
        _isBusy = false;
        _retriesLeft = MAX_RETRIES;
    }

    public function getMessage(): Message {
        return _msg;
    }

    public function sendToChannel(translationId: String, ?vars: Array<String>, variant: Int = 0, ?callback: Dynamic->Message->Void): Void {
        var serverId: String = DiscordUtils.getServerIdFromMessage(_msg);

        rawSendToChannel(LangCenter.instance.translate(serverId, translationId, vars, variant), callback);
    }

    public function reply(translationId: String, ?vars: Array<String>, variant: Int = 0, ?callback: Dynamic->Message->Void): Void {
        sendToChannel(translationId, vars, variant, callback);
    }

    public function sendToAuthor(translationId: String, ?vars: Array<String>, variant: Int = 0, ?callback: Dynamic->Message->Void): Void {
        rawSendToAuthor(LangCenter.instance.translate(Config.KEY_ALL, translationId, vars, variant), callback);
    }

    public function sendToOwner(translationId: String, ?vars: Array<String>, variant: Int = 0, ?callback: Dynamic->Message->Void): Void {
        rawSendToOwner(LangCenter.instance.translate(Config.KEY_ALL, translationId, vars, variant), callback);
    }

    public function sendTo(destination: ChannelResolvable, translationId: String, ?vars: Array<String>, variant: Int = 0, ?callback: Dynamic->Message->Void): Void {
        rawSendTo(destination, LangCenter.instance.translate(Config.KEY_ALL, translationId, vars, variant), callback);
    }

    public function rawSendToChannel(text: String, ?callback: Dynamic->Message->Void): Void {
        sendMessage(_msg.channel, text, callback);
    }

    public function rawReply(text: String, ?callback: Dynamic->Message->Void): Void {
        rawSendToChannel(text, callback);
    }

    public function rawSendToAuthor(text: String, ?callback: Dynamic->Message->Void): Void {
        sendMessage(_msg.author, text, callback);
    }

    public function rawSendToOwner(text: String, ?callback: Dynamic->Message->Void): Void {
        sendMessage(DiscordUtils.getOwnerInstance(), text, callback);
    }

    public function rawSendTo(destination: ChannelResolvable, text: String, ?callback: Dynamic->Message->Void): Void {
        sendMessage(destination, text, callback);
    }

    private function sendMessage(destination: ChannelResolvable, content: String, ?callback: Dynamic->Message->Void, flushing: Bool = false): Void {
        if (!_isBusy || flushing) {
            trySendingMessage(destination, content, callback);
        } else {
            _pool.push({
                destination: destination,
                content: content,
                callback: callback
            });
        }
    }

    private function trySendingMessage(destination: ChannelResolvable, content: String, ?callback: Dynamic->Message->Void): Void {
        _client.sendMessage(destination, content, cast {tts: false}, function (err: Dynamic, msg: Message): Void {
            if (err != null && _retriesLeft > 0) {
                Logger.error('Message not sent, retrying...');

                _isBusy = true;
                _retriesLeft--;

                trySendingMessage(destination, content, callback);
            } else {
                if (err != null) {
                    Logger.error('Could not send message, giving up');
                } else if (_isBusy) {
                    Logger.info('Message successfully sent after retries');
                }

                callback(err, msg);
                resetBusyState();
            }
        });
    }

    private function resetBusyState() {
        flushPool();
    }

    private function flushPool() {
        if (_pool.length > 0) {
            var message = _pool.shift();

            sendMessage(message.destination, message.content, function (err: Dynamic, msg: Message): Void {
                if (message.callback != null) {
                    message.callback(err, msg);
                }

                flushPool();
            }, true);
        } else {
            _isBusy = false;
            _retriesLeft = MAX_RETRIES;
        }
    }
}

typedef DelayedMessage = {
    destination: ChannelResolvable,
    content: String,
    callback: Dynamic->Message->Void
}
