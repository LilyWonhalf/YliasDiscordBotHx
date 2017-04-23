package yliasdiscordbothx.model.commandlist;

import discordbothx.service.DiscordUtils;
import yliasdiscordbothx.utils.YliasDiscordUtils;
import Reflect;
import discordhx.RichEmbed;
import discordbothx.core.CommunicationContext;
import discordbothx.log.Logger;
import haxe.Json;
import yliasdiscordbothx.utils.HttpQuery;

class Wiki extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(language prefix) (search)';
        nbRequiredParams = 2;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;

        var language = args.shift();
        var host = language + '.wikipedia.org';
        var path = '/w/api.php?action=query&prop=extracts&exintro&explaintext&format=json&redirects=1&titles=';
        var query: HttpQuery = new HttpQuery(host, path + StringTools.urlEncode(args.join(' ')));

        query.send().then(function (data: String) {
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
                    context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                        'Wikipedia',
                        YliasDiscordUtils.getCleanString(context, l('not_found', cast [author])),
                        Emotion.SURPRISE
                    ));
                }
            } else {
                Logger.error('Failed to search on wikipedia (step 1), URL: https://' + host + path);
                context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                    'Wikipedia',
                    YliasDiscordUtils.getCleanString(context, l('fail', cast [author])),
                    Emotion.SAD
                ));
            }
        });
    }
}
