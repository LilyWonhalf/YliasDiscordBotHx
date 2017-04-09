package yliasdiscordbothx.model.commandlist;

import yliasdiscordbothx.utils.DiscordUtils;
import yliasdiscordbothx.utils.ArrayUtils;
import discordbothx.core.CommunicationContext;
import discordbothx.log.Logger;
import haxe.Json;
import yliasdiscordbothx.utils.HttpQuery;

class Obf extends YliasBaseCommand {
    private static inline var ITERATIONS = 8;

    private var basePath: String;
    private var iterationsLeft: Int;
    private var languages: Array<String>;
    private var sourceLanguage: String;

    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(2-letters language) (text)';
        nbRequiredParams = 2;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var lang: String = args.shift();
        var text: String = args.join(' ');

        languages = [
            'af',
            'sq',
            'az',
            'eu',
            'ca',
            'hr',
            'cs',
            'da',
            'nl',
            'en',
            'eo',
            'et',
            'tl',
            'fi',
            'fr',
            'gl',
            'de',
            'ht',
            'hu',
            'is',
            'id',
            'ga',
            'it',
            'la',
            'lv',
            'lt',
            'ms',
            'mt',
            'no',
            'pl',
            'pt',
            'ro',
            'sk',
            'sl',
            'es',
            'sw',
            'sv',
            'tr',
            'vi',
            'cy'
        ];

        if (languages.indexOf(lang) > -1) {
            sourceLanguage = lang;
            iterationsLeft = ITERATIONS;
            basePath = '/translate_a/single';
            basePath += '?ie=UTF-8';
            basePath += '&oe=UTF-8';
            basePath += '&multires=1';
            basePath += '&client=gtx';
            basePath += '&dt=t';

            languages.remove(sourceLanguage);

            DiscordUtils.setTyping(true, context.message.channel);
            translateFrom(text, sourceLanguage);
        } else {
            context.sendToChannel(l('wrong_language', cast [author]));
        }
    }

    private function translateFrom(text: String, lang: String): Void {
        var author = context.message.author;
        var path: String = basePath;
        var query: HttpQuery = new HttpQuery('translate.googleapis.com');
        var targetLanguage: String = ArrayUtils.random(languages);

        if (iterationsLeft < 1) {
            targetLanguage = sourceLanguage;
        } else {
            languages.remove(targetLanguage);
        }

        path += '&sl=' + lang;
        path += '&tl=' + targetLanguage;
        path += '&q=' + StringTools.urlEncode(text);

        query.path = path;

        query.send().then(function (data: String) {
            var response: Dynamic = null;

            try {
                response = Json.parse(data);
            } catch (err: Dynamic) {
                Logger.exception(err);
            }

            if (response != null) {
                var textParts: Array<Array<String>> = cast response[0];

                text = '';

                for (i in 0...textParts.length) {
                    text += textParts[i][0];
                }

                if (iterationsLeft > 0) {
                    iterationsLeft--;
                    translateFrom(text, targetLanguage);
                } else {
                    DiscordUtils.setTyping(false, context.message.channel);
                    context.sendToChannel(l('answer', cast [author]) + '\n\n' + text);
                }
            } else {
                DiscordUtils.setTyping(false, context.message.channel);
                context.sendToChannel(l('fail', cast [author]));
            }
        });
    }
}
