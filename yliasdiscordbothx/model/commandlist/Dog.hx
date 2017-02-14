package yliasdiscordbothx.model.commandlist;

import discordbothx.core.CommunicationContext;
import nodejs.http.HTTP.HTTPMethod;
import discordbothx.log.Logger;
import yliasdiscordbothx.utils.HttpUtils;

class Dog extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;

        HttpUtils.query(false, 'random.dog', '/woof', cast HTTPMethod.Get, function (data: String) {
            if (data != null && data.split('\n').length < 2) {
                context.sendFileToChannel('http://random.dog/' + data, data, author.toString());
            } else {
                Logger.error('Failed to load a dog picture');
                context.sendToChannel(l('fail', cast [author]));
            }
        });
    }
}
