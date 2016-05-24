package model.commandlist;

import StringTools;
import translations.L;
import nodejs.NodeJS;
import external.discord.client.Client;
import external.discord.message.Message;

class Scream implements ICommandDefinition {
    public var paramsUsage = '';
    public var description = L.a.n.g('model.commandlist.scream.description');
    public var hidden = false;

    private var _screamList: Array<ScreamDetail>;

    public function process(msg: Message, args: Array<String>): Void {
        var client: Client = cast NodeJS.global.client;
        var scream: String = 'awoo';
        var emoji: String = ':waxing_gibbous_moon:';
        var renderedScream: String = null;
        var multipliedLetter: String = null;

        _screamList = new Array<ScreamDetail>();

        _screamList.push({
            scream: 'awoo',
            renderedScream: 'AWOO%%',
            multipliedLetter: 'O',
            emoji: ':full_moon:'
        });
        _screamList.push({
            scream: 'ahou',
            renderedScream: 'AHO%%U',
            multipliedLetter: 'O',
            emoji: ':full_moon:'
        });
        _screamList.push({
            scream: 'bark',
            renderedScream: 'BRR%% BARK',
            multipliedLetter: 'R',
            emoji: ':dog:'
        });
        _screamList.push({
            scream: 'ouaf',
            renderedScream: 'GRR%% OUAF',
            multipliedLetter: 'R',
            emoji: ':dog:'
        });
        _screamList.push({
            scream: 'meow',
            renderedScream: 'ME%%OW',
            multipliedLetter: 'E',
            emoji: ':cat:'
        });
        _screamList.push({
            scream: 'miaou',
            renderedScream: 'MIA%%OU',
            multipliedLetter: 'A',
            emoji: ':cat:'
        });
        _screamList.push({
            scream: 'squee',
            renderedScream: 'SQUEE%%',
            multipliedLetter: 'E',
            emoji: ''
        });
        _screamList.push({
            scream: 'grawr',
            renderedScream: 'GRA%%WR',
            multipliedLetter: 'A',
            emoji: ''
        });
        _screamList.push({
            scream: 'rawr',
            renderedScream: 'RA%%WR',
            multipliedLetter: 'A',
            emoji: ''
        });
        _screamList.push({
            scream: 'grou',
            renderedScream: 'GRO%%U',
            multipliedLetter: 'O',
            emoji: ':smiley_cat:'
        });
        _screamList.push({
            scream: 'ui',
            renderedScream: 'UI%%',
            multipliedLetter: 'I',
            emoji: ':ok_hand:'
        });

        if (args.length > 0 && StringTools.trim(args[0]).length > 0) {
            scream = args[0].toLowerCase();
            emoji = '';
        }

        for (screamDetail in _screamList) {
            var regexp = new EReg('^' + screamDetail.scream, '');

            if (regexp.match(scream)) {
                renderedScream = screamDetail.renderedScream;
                multipliedLetter = screamDetail.multipliedLetter;
                emoji = screamDetail.emoji;
                break;
            }
        }

        if (renderedScream == null) {
            if (~/[aeiouy]/.match(scream)) {
                var vowel: String = null;
                var vowelsOnlyScream: String = null;
                var doubleVowelsRegexp: EReg = ~/([aeiouy])\1/;

                if (doubleVowelsRegexp.match(scream)) {
                    vowelsOnlyScream = doubleVowelsRegexp.matched(0);
                } else {
                    vowelsOnlyScream = ~/[^aeiouy]/g.replace(scream, '');
                }

                vowel = vowelsOnlyScream.charAt(Math.floor(Math.random() * (vowelsOnlyScream.length)));
                var vowelPosition = scream.lastIndexOf(vowel);

                renderedScream = scream.substr(0, vowelPosition + 1) + '%%' + scream.substr(vowelPosition + 1);
                renderedScream = renderedScream.toUpperCase();
                multipliedLetter = vowel.toUpperCase();
            } else {
                multipliedLetter = scream.charAt(Math.floor(Math.random() * (scream.length)));
                var firstPosition = scream.indexOf(multipliedLetter);

                renderedScream = scream.substr(0, firstPosition + 1) + '%%' + scream.substr(firstPosition + 1);
                renderedScream = renderedScream.toUpperCase();
                multipliedLetter = multipliedLetter.toUpperCase();
            }
        }

        for (i in 0...Math.floor(Math.random() * (42))) {
            multipliedLetter += multipliedLetter.substr(0, 1);
        }

        renderedScream = StringTools.replace(renderedScream, '%%', multipliedLetter);

        client.sendMessage(msg.channel, msg.author + ' => ' + emoji + ' ' + renderedScream);
    }
}

typedef ScreamDetail = {
    scream: String,
    renderedScream: String,
    multipliedLetter: String,
    emoji: String
}
