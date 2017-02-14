package yliasdiscordbothx.model.commandlist;

import discordbothx.service.DiscordUtils;
import Reflect;
import discordhx.RichEmbed;
import discordbothx.core.CommunicationContext;
import discordbothx.log.Logger;
import haxe.Json;
import nodejs.http.HTTP.HTTPMethod;
import yliasdiscordbothx.utils.HttpUtils;

class Wiki extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(language prefix) (search)';
        nbRequiredParams = 2;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;

        if (args.length > 1) {
            var language = args.shift();
            var host = language + '.wikipedia.org';
            var path = '/w/api.php?action=query&prop=extracts&exintro&explaintext&format=json&redirects=1&titles=';

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
                        var extract:String = Reflect.field(parsedData, 'extract');

                        if (extract.length > 1000) {
                            extract = extract.substr(0, 1000) + '...';
                        }

                        var embed: RichEmbed = new RichEmbed();

                        embed.setURL('https://' + host + '/wiki/' + StringTools.urlEncode(parsedData.title));
                        embed.setTitle(parsedData.title);
                        embed.setDescription(extract);
                        embed.setColor(DiscordUtils.getMaterialUIColor());

                        context.sendEmbedToChannel(embed, author.toString());
                    } else {
                        Logger.error('Failed to search on wikipedia (step 2), URL: https://' + host + path);
                        context.sendToChannel(l('not_found', cast [author]));
                    }
                } else {
                    Logger.error('Failed to search on wikipedia (step 1), URL: https://' + host + path);
                    context.sendToChannel(l('fail', cast [author]));
                }
            });
        } else {
            context.sendToChannel(l('parse_error', cast [author]));
        }
    }
}
