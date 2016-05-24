package utils;

import translations.L;

class Humanify {
    public static function getMultimediaContentDeliverySentence(): String {
        var imageDeliverySentences: Array<String> = [
            L.a.n.g('utils.humanify.getimagedeliverysentence.1'),
            L.a.n.g('utils.humanify.getimagedeliverysentence.2'),
            L.a.n.g('utils.humanify.getimagedeliverysentence.3'),
            L.a.n.g('utils.humanify.getimagedeliverysentence.4'),
            L.a.n.g('utils.humanify.getimagedeliverysentence.5')
        ];

        return ArrayUtils.random(imageDeliverySentences);
    }

    public static function getChoiceDeliverySentence(choice: String): String {
        var choiceDeliverySentences: Array<String> = [
            L.a.n.g('utils.humanify.getchoicedeliverysentence.1', [choice]),
            L.a.n.g('utils.humanify.getchoicedeliverysentence.2', [choice]),
            L.a.n.g('utils.humanify.getchoicedeliverysentence.3', [choice]),
            L.a.n.g('utils.humanify.getchoicedeliverysentence.4', [choice])
        ];

        return ArrayUtils.random(choiceDeliverySentences);
    }

    public static function getBooleanValue(str: String): Bool {
        var ret: Bool = null;
        var stringsThatMeanTrue: Array<String> = [
            'ye',
            'yee',
            'yes',
            'yeah',
            'yea',
            'ui',
            'oui',
            'ouip',
            'ouai',
            'ouais',
            'ouaip',
            'ya',
            'yep',
            'yup',
            'yip',
            'yay',
            '1',
            'true',
            'vrai'
        ];
        var stringsThatMeanFalse: Array<String> = [
            'no',
            'noo',
            'noes',
            'noe',
            'non',
            'na',
            'nu',
            'niu',
            'nyu',
            'nuu',
            'niuu',
            'nyuu',
            'nuuu',
            'niuuu',
            'nyuuu',
            'nan',
            'naan',
            'nope',
            'nop',
            'nay',
            '0',
            'false',
            'faux'
        ];

        if (stringsThatMeanTrue.indexOf(str) > -1) {
            ret = true;
        } else if (stringsThatMeanFalse.indexOf(str) > -1) {
            ret = false;
        }

        return ret;
    }
}
