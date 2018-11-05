package yliasdiscordbothx.translations;

import discordbothx.log.Logger;
import Reflect;
import haxe.Json;
import yliasdiscordbothx.system.FileSystem;
import yliasdiscordbothx.translations.Lang;

class Translator {
    private var translations: Map<String, Dynamic>;

    public function new() {
        var files: Array<FileInfo> = FileSystem.getFilesInFolder('yliasdiscordbothx/translations/data', 'json');

        translations = new Map<String, Map<String, Array<String>>>();

        for (file in files) {
            var language = ~/\..+$/ig.replace(file.name, '');
            var data = Json.parse(file.content);

            translations.set(language, data);
        }
    }

    public function getTranslation(lang: Lang, str: String, ?vars: Array<String>, variant: Int = 0): String {
        var ret: String = str;

        if (translations.exists(cast lang)) {
            var langData: Dynamic = translations.get(cast lang);
            var path: Array<String> = str.split('.');

            for (pathElement in path) {
                if (Reflect.hasField(langData, pathElement)) {
                    langData = Reflect.getProperty(langData, pathElement);

                    if (Std.is(langData, Array)) {
                        ret = cast(langData, Array<Dynamic>)[variant];
                    }
                } else {
                    Logger.warning('Couldn\'t find translation data for key ' + str);
                    break;
                }
            }

            if (vars != null) {
                for (replacement in vars) {
                    ret = ~/%%/.replace(ret, replacement);
                }
            }
        } else {
            Logger.debug(lang);
            Logger.debug(translations);
        }

        return ret;
    }
}
