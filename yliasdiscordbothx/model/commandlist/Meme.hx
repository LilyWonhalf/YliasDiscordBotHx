package yliasdiscordbothx.model.commandlist;

import yliasdiscordbothx.utils.YliasDiscordUtils;
import discordbothx.core.CommunicationContext;
import yliasdiscordbothx.Bot;
import yliasdiscordbothx.external.imgflipper.Imgflipper;
import discordbothx.log.Logger;
import yliasdiscordbothx.model.entity.Meme as MemeEntity;

class Meme extends YliasBaseCommand {
    public function new(context: CommunicationContext) {
        super(context);

        paramsUsage = '(type) "(top text)" *"(bottom text)"*';
        nbRequiredParams = 2;
    }

    override public function process(args: Array<String>): Void {
        var author = context.message.author;
        var nbQuotes = ~/[^"]*/g.replace(args.join(' '), '').length;

        if (nbQuotes == 2 || nbQuotes == 4) {
            var uniqueValues = new Map<String, String>();
            var meme = new MemeEntity();

            uniqueValues.set('name', args[0]);

            meme.retrieve(uniqueValues, function (found) {
                if (found) {
                    var top = ' ';
                    var bottom = ' ';
                    var splitted = args.join(' ').split('"');
                    var imgflipper = new Imgflipper(Bot.instance.authDetails.IMGFLIP_USERNAME, Bot.instance.authDetails.IMGFLIP_PASSWORD);

                    if (splitted[1].length > 0) {
                        top = splitted[1];
                    }

                    if (nbQuotes == 4 && splitted[3].length > 0) {
                        bottom = splitted[3];
                    }

                    imgflipper.generateMeme(meme.id, top, bottom, function (err: Dynamic, image: String) {
                        if (!err) {
                            context.sendFileToChannel(image, 'meme.jpg', author.toString());
                        } else {
                            Logger.exception(err);
                            Logger.debug(meme);
                            context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                                'Meme',
                                YliasDiscordUtils.getCleanString(context, l('fail', cast [author])),
                                Emotion.SAD
                            ));
                        }
                    });
                } else {
                    context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                        'Meme',
                        YliasDiscordUtils.getCleanString(context, l('not_found', cast [author])),
                        Emotion.SAD
                    ));
                }
            });
        } else {
            context.sendEmbedToChannel(YliasDiscordUtils.getEmbeddedMessage(
                'Meme',
                YliasDiscordUtils.getCleanString(context, l('parse_error', cast [author])),
                Emotion.UNAMUSED
            ));
        }
    }

    override public function checkFormat(args: Array<String>): Bool {
        var nbQuotes = ~/[^"]*/g.replace(args.join(' '), '').length;

        return super.checkFormat(args) && (nbQuotes == 2 || nbQuotes == 4);
    }
}
