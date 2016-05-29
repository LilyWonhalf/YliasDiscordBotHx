package model.commandlist;

import utils.DiscordUtils;
import external.imgflipper.Imgflipper;
import config.AuthDetails;
import utils.Logger;
import translations.LangCenter;
import model.entity.Meme as MemeEntity;

class Meme implements ICommandDefinition {
    public var paramsUsage = '(type) "(top text)" *"(bottom text)"*';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.meme.description');
    }

    public function process(args: Array<String>): Void {
        var author = _context.getMessage().author;
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
                    var imgflipper = new Imgflipper(AuthDetails.IMGFLIP_USERNAME, AuthDetails.IMGFLIP_PASSWORD);

                    if (splitted[1].length > 0) {
                        top = splitted[1];
                    }

                    if (nbQuotes == 4 && splitted[3].length > 0) {
                        bottom = splitted[3];
                    }

                    imgflipper.generateMeme(meme.id, top, bottom, function (err: Dynamic, image: String) {
                        if (err) {
                            Logger.exception(err);
                            Logger.debug(meme);
                            _context.sendToChannel('model.commandlist.meme.process.fail', cast [author]);
                        } else {
                            _context.rawSendToChannel(author + ' => ' + image);
                        }
                    });
                } else {
                    _context.sendToChannel('model.commandlist.meme.process.not_found', cast [author]);
                }
            });
        } else {
            _context.sendToChannel('model.commandlist.meme.process.parse_error', cast [author]);
        }
    }
}
