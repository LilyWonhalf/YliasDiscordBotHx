package model.commandlist;

import utils.DiscordUtils;
import utils.Logger;
import haxe.Json;
import nodejs.http.HTTP.HTTPMethod;
import utils.HttpUtils;
import translations.LangCenter;

class Wiki implements ICommandDefinition {
    public var paramsUsage = '(search)';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.wiki.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;
        var host = '.wikipedia.org';
        var path = '/w/api.php?action=query&prop=extracts&exintro&explaintext&format=json&redirects=1&titles=';

        switch (LangCenter.instance.getLang(DiscordUtils.getServerIdFromMessage(_context.getMessage()))) {
            case Lang.fr_FR:
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
                        _context.rawSendToChannel(author + ' => ' + Reflect.field(parsedData, 'extract') + '\n\n<https://' + host + '/wiki/' + parsedData.title + '>');
                    } else {
                        Logger.error('Failed to search on wikipedia (step 2)');
                        _context.sendToChannel('model.commandlist.wiki.process.not_found', cast [author]);
                    }
                } else {
                    Logger.error('Failed to search on wikipedia (step 1)');
                    _context.sendToChannel('model.commandlist.wiki.process.fail', cast [author]);
                }
            });
        } else {
            _context.sendToChannel('model.commandlist.wiki.process.parse_error', cast [author]);
        }
    }
}
