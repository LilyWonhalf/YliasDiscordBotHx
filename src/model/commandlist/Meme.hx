package model.commandlist;

import external.imgflipper.Imgflipper;
import config.AuthDetails;
import utils.Logger;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;
import model.entity.Meme as MemeEntity;

class Meme implements ICommandDefinition {
    public var paramsUsage = '(type) "(top text)" *"(bottom text)"*';
    public var description = L.a.n.g('model.commandlist.meme.description');
    public var hidden = false;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;
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
                            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.meme.process.fail', cast [msg.author]));
                        } else {
                            client.sendMessage(msg.channel, msg.author + ' => ' + image);
                        }
                    });
                } else {
                    client.sendMessage(msg.channel, L.a.n.g('model.commandlist.meme.process.not_found', cast [msg.author]));
                }
            });
        } else {
            client.sendMessage(msg.channel, L.a.n.g('model.commandlist.meme.process.parse_error', cast [msg.author]));
        }
    }
}
