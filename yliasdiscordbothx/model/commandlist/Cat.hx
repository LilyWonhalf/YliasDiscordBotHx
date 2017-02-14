package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import nodejs.http.HTTP.HTTPMethod;
import discordbothx.log.Logger;
import haxe.Json;
import yliasdiscordbothx.utils.HttpUtils;

class Cat extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;

        HttpUtils.query(false, 'random.cat', '/meow', cast HTTPMethod.Get, function (data: String) {
            var response: Dynamic = null;

            try {
                response = Json.parse(data);
            } catch (err: Dynamic) {
                Logger.exception(err);
            }

            if (response != null && Reflect.hasField(response, 'file')) {
                context.sendFileToChannel(response.file, 'cat.jpg', author.toString());
            } else {
                Logger.error('Failed to load a cat picture');
                context.sendToChannel(l('fail', cast [author]));
            }
        });
    }
}
