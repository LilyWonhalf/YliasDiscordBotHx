package model;

import config.Config;
import utils.DiscordUtils;
import translations.LangCenter;
import external.discord.message.Message;
import external.discord.client.Client;

class CommunicationContext {
    private var _client: Client;
    private var _msg: Message;

    public function new(client: Client, msg: Message) {
        _client = client;
        _msg = msg;
    }

    public function getMessage(): Message {
        return _msg;
    }

    public function sendToChannel(translationId: String, ?vars: Array<String>, variant: Int = 0, ?callback: Dynamic->Message->Void): Void {
        var serverId: String = DiscordUtils.getServerIdFromMessage(_msg);

        rawSendToChannel(LangCenter.instance.translate(serverId, translationId, vars, variant), callback);
    }

    public function sendToAuthor(translationId: String, ?vars: Array<String>, variant: Int = 0, ?callback: Dynamic->Message->Void): Void {
        rawSendToAuthor(LangCenter.instance.translate(Config.KEY_ALL, translationId, vars, variant), callback);
    }

    public function sendToOwner(translationId: String, ?vars: Array<String>, variant: Int = 0, ?callback: Dynamic->Message->Void): Void {
        rawSendToOwner(LangCenter.instance.translate(Config.KEY_ALL, translationId, vars, variant), callback);
    }

    public function rawSendToChannel(text: String, ?callback: Dynamic->Message->Void): Void {
        _client.sendMessage(_msg.channel, text, cast {tts: false}, callback);
    }

    public function rawSendToAuthor(text: String, ?callback: Dynamic->Message->Void): Void {
        _client.sendMessage(_msg.author, text, cast {tts: false}, callback);
    }

    public function rawSendToOwner(text: String, ?callback: Dynamic->Message->Void): Void {
        _client.sendMessage(DiscordUtils.getOwnerInstance(), text, cast {tts: false}, callback);
    }
}
