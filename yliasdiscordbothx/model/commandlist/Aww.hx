package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import StringTools;
import yliasdiscordbothx.utils.ArrayUtils;
import haxe.Json;
import nodejs.http.HTTP.HTTPMethod;
import discordbothx.log.Logger;
import yliasdiscordbothx.utils.HttpUtils;

class Aww extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var bestArray: Array<String> = new Array<String>();
        var path = '/r/aww/new.json?count=100';

        bestArray.push('best');
        bestArray.push('top');
        bestArray.push('better');
        bestArray.push('hot');

        if (args.length > 0 && bestArray.indexOf(StringTools.trim(args[0])) > -1) {
            path = '/r/aww/.json?count=100';
        }

        HttpUtils.query(true, 'www.reddit.com', path, cast HTTPMethod.Get, function (data: String) {
            var response: Dynamic = null;

            try {
                response = Json.parse(data);
            } catch (err: Dynamic) {
                Logger.exception(err);
            }

            if (response != null && Reflect.hasField(response, 'data') && Reflect.hasField(Reflect.field(response, 'data'), 'children')) {
                var children: Array<Dynamic> = response.data.children;

                children = children.filter(function (e: Dynamic): Bool {
                    var data = Reflect.field(e, 'data');
                    var hasPreview = Reflect.hasField(data, 'preview');
                    var hasImages = hasPreview && Reflect.hasField(Reflect.field(data, 'preview'), 'images');

                    return hasImages;
                });

                var picture = ArrayUtils.random(children);
                var linkSentence = l('link_to_the_topic');

                context.sendToChannel(author + ', ' + ~/&amp;/g.replace(picture.data.url, '&') + '\n\n' + linkSentence + ' <https://www.reddit.com' + picture.data.permalink + '>');
            } else {
                Logger.error('Failed to load a cat picture');
                context.sendToChannel(l('fail', cast [author]));
            }
        });
    }
}
