package model.commandlist;

import nodejs.http.HTTP.HTTPMethod;
import utils.Logger;
import haxe.Json;
import utils.HttpUtils;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class Cat implements ICommandDefinition {
    public var paramsUsage = '';
    public var description = L.a.n.g('model.commandlist.cat.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;

        HttpUtils.query(false, 'random.cat', '/meow', cast HTTPMethod.Get, function (data: String) {
            var response: Dynamic = null;

            try {
                response = Json.parse(data);
            } catch (err: Dynamic) {
                Logger.exception(err);
            }

            if (response != null && Reflect.hasField(response, 'file')) {
                client.sendMessage(msg.channel, msg.author + ' => ' + response.file);
            } else {
                Logger.error('Failed to load a cat picture');
                client.sendMessage(msg.channel, L.a.n.g('model.commandlist.cat.process.fail', cast [msg.author]));
            }
        });
    }
}
