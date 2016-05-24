package model.commandlist;

import utils.Logger;
import haxe.Json;
import nodejs.http.HTTP.HTTPMethod;
import utils.HttpUtils;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class Wiki implements ICommandDefinition {
    public var paramsUsage = '(search)';
    public var description = L.a.n.g('model.commandlist.wiki.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;
        var host = '.wikipedia.org';
        var path = '/w/api.php?action=query&prop=extracts&exintro&explaintext&format=json&redirects=1&titles=';

        switch (L.a.getLang()) {
            case Language.fr_FR:
                host = 'fr' + host;

            default:
                host = 'en' + host;
        }

        if (args.length > 0) {
            HttpUtils.query(true, host, path + StringTools.urlEncode(args.join(' ')), cast HTTPMethod.Get, function (data: String) {
                var parsedData: Dynamic;

                try {
                    parsedData = Json.parse(data);
                    parsedData = parsedData.query.pages;
                } catch (e: Dynamic) {
                    Logger.exception(e);
                    parsedData = null;
                }

                if (parsedData != null) {
                    var firstPageId = Reflect.fields(parsedData)[0];

                    if (firstPageId != '-1' && Reflect.hasField(parsedData, firstPageId) && Reflect.hasField(Reflect.field(parsedData, firstPageId), 'extract')) {
                        parsedData = Reflect.field(parsedData, firstPageId);
                        client.sendMessage(msg.channel, msg.author + ' => ' + Reflect.field(parsedData, 'extract'));
                    } else {
                        Logger.error('Failed to search on wikipedia (step 2)');
                        client.sendMessage(msg.channel, L.a.n.g('model.commandlist.wiki.process.not_found', cast [msg.author]));
                    }
                } else {
                    Logger.error('Failed to search on wikipedia (step 1)');
                    client.sendMessage(msg.channel, L.a.n.g('model.commandlist.wiki.process.fail', cast [msg.author]));
                }
            });
        } else {
            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.wiki.process.parse_error', cast [msg.author]));
        }
    }
}
