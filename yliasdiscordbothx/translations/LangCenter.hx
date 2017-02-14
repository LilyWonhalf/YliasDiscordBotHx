package yliasdiscordbothx.translations;

import haxe.PosInfos;
import yliasdiscordbothx.model.Entity;
import yliasdiscordbothx.model.entity.ServerLang;

class LangCenter {
    private static inline var DEFAULT_LANG = Lang.fr_FR;

    public static var instance(get, null): LangCenter;

    private var langMap: Map<String, Lang>;
    private var translator: Translator;

    public static function get_instance(): LangCenter {
        if (instance == null) {
            instance = new LangCenter();
        }

        return instance;
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

        langMap.set(idServer, lang);
    }

    public function getLang(idServer: String): Lang {
        var ret: Lang = DEFAULT_LANG;

        if (langMap.exists(idServer)) {
            ret = langMap.get(idServer);
        }

        return ret;
    }

    public function translate(serverId: String, translationId: String, ?vars: Array<String>, variant: Int = 0, ?pos: PosInfos): String {
        var lang: Lang = DEFAULT_LANG;

        if (langMap.exists(serverId)) {
            lang = langMap.get(serverId);
        }

        if (translationId.indexOf(Bot.PROJECT_NAME) < 0) {
            translationId = pos.className.toLowerCase() + '.' + pos.methodName.toLowerCase() + '.' + translationId;
        }

        return translator.getTranslation(lang, translationId, vars, variant);
    }

    private function new() {
        langMap = new Map<String, Lang>();
        translator = new Translator();

        retrieveLangs();
    }

    private function retrieveLangs(): Void {
        Entity.getAll(ServerLang, function (parameters: Array<ServerLang>) {
            for (parameter in parameters) {
                langMap.set(parameter.idServer, parameter.lang);
            }
        });
    }
}
