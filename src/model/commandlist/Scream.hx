package model.commandlist;

import utils.DiscordUtils;
import js.RegExp;
import StringTools;
import translations.LangCenter;

class Scream implements ICommandDefinition {
    public var paramsUsage = '(custom scream)';
    public var description: String;
    public var hidden = false;

    private var _context: CommunicationContext;
    private var _screamList: Array<ScreamDetail>;

    public function new(context: CommunicationContext) {
        var serverId = DiscordUtils.getServerIdFromMessage(context.getMessage());

        _context = context;
        description = LangCenter.instance.translate(serverId, 'model.commandlist.scream.description');
    }

    public function process(args: Array<String>): Void {
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
        _screamList.push({
            scream: 'yiff',
            renderedScream: 'YI%%FF',
            multipliedLetter: 'I',
            emoji: ':underage:'
        });

        if (args.length > 0 && StringTools.trim(args.join(' ')).length > 0) {
            scream = args.join(' ').toLowerCase();
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
            if (~/[aeiouy]/g.match(scream)) {
                var vowel: String = null;
                var vowelPosition: Int = null;
                var regexpResult: RegExpMatch = null;

                if (~/([aeiouy])\1/g.match(scream)) {
                    var doubleVowelsRegexp: RegExp = new RegExp('([aeiouy])\\1', 'g');

                    do {
                        if (regexpResult != null) {
                            vowel = regexpResult[1];
                            vowelPosition = regexpResult.index;
                        }

                        regexpResult = doubleVowelsRegexp.exec(scream);
                    } while (regexpResult != null);
                } else {
                    var simpleVowelsRegexp: RegExp = new RegExp('([aeiouy])', 'g');
                    var consonantRegexp: EReg = ~/([^aeiouy])/g;
                    var screamReadyForSearch: String = scream;
                    var lastCharacterIsE = scream.charAt(scream.length - 1) == 'e';
                    var penultimateCharacterIsConsonant = consonantRegexp.match(scream.charAt(scream.length - 2));

                    if (lastCharacterIsE && penultimateCharacterIsConsonant) {
                        screamReadyForSearch = scream.substr(0, scream.length - 1);
                    }

                    do {
                        if (regexpResult != null) {
                            vowel = regexpResult[1];
                            vowelPosition = regexpResult.index;
                        }

                        regexpResult = simpleVowelsRegexp.exec(screamReadyForSearch);
                    } while (regexpResult != null);
                }

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
        _context.rawSendToChannel(_context.getMessage().author + ' => ' + emoji + ' ' + renderedScream);
    }
}

typedef ScreamDetail = {
    scream: String,
    renderedScream: String,
    multipliedLetter: String,
    emoji: String
}
