package translations;

import model.Entity;
import model.entity.ServerLang;

class LangCenter {
    private static inline var DEFAULT_LANG = Lang.fr_FR;

    public static var instance(get, null): LangCenter;

    private static var _instance: LangCenter;

    private var _langMap: Map<String, Lang>;
    private var _translator: Translator;

    public static function get_instance(): LangCenter {
        if (_instance == null) {
            _instance = new LangCenter();
        }

        return _instance;
    }

    public function setLang(idServer: String, lang: Lang): Void {
        var serverLang = new ServerLang();
        var uniqueValue = new Map<String, String>();

        uniqueValue.set('idServer', idServer);

        serverLang.retrieve(uniqueValue, function (found: Bool) {
            if (!found) {
                serverLang.idServer = idServer;
            }

            serverLang.lang = lang;
            serverLang.save();
        });

        _langMap.set(idServer, lang);
    }

    public function getLang(idServer: String): Lang {
        var ret: Lang = cast DEFAULT_LANG;

        if (_langMap.exists(idServer)) {
            ret = _langMap.get(idServer);
        }

        return ret;
    }

    public function translate(idServer: String, translationId: String, ?vars: Array<String>, variant: Int = 0): String {
        var lang: Lang = DEFAULT_LANG;

        if (_langMap.exists(idServer)) {
            lang = _langMap.get(idServer);
        }

        return _translator.getTranslation(lang, translationId, vars, variant);
    }

    private function new() {
        _langMap = new Map<String, Lang>();
        _translator = new Translator();

        _retrieveLangs();
    }

    private function _retrieveLangs(): Void {
        Entity.getAll(ServerLang, function (parameters: Array<ServerLang>) {
            for (parameter in parameters) {
                _langMap.set(parameter.idServer, parameter.lang);
            }
        });
    }
}

@:enum
abstract Lang(String) {
    var fr_FR = 'fr_FR';
    var en_GB = 'en_GB';
}