package yliasdiscordbothx.model.commandlist;

import yliasdiscordbothx.utils.YliasDiscordUtils;
import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.translations.LangCenter;
import yliasdiscordbothx.utils.Humanify;
import yliasdiscordbothx.utils.ArrayUtils;

class Decide extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(thing) ' + l('split') + ' (other thing)';
        nbRequiredParams = 3;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var idServer = YliasDiscordUtils.getServerIdFromMessage(context.message);

        args = args.join(' ').split(' ' + l('split') + ' ');

        var picked = ArrayUtils.random(args);
        var sentence = LangCenter.instance.translate(idServer, Humanify.getChoiceDeliverySentence(), [picked]);

        context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
            'Decide',
            YliasDiscordUtils.getCleanString(context, sentence),
            Emotion.NEUTRAL
        ), cast author);
    }

    override public function checkFormat(args: Array<String>): Bool {
        var parsedArgs: Array<String> = args.join(' ').split(' ' + l('split') + ' ');

        return super.checkFormat(args) && parsedArgs.length > 1;
    }
}
