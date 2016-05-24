package translations;

import haxe.Json;
import system.FileSystem;
import translations.L.Language;

class Translator {
    private var _translations: Map<String, Map<String, Array<String>>>;
    private var _language: Language;

    public function new() {
        var files: Array<FileInfo> = FileSystem.getFilesInFolder('translations/data/', 'json');

        _translations = new Map<String, Map<String, Array<String>>>();

        for (file in files) {
            var language = ~/\..+$/ig.replace(file.name, '');
            var castData = new Map<String, Array<String>>();
            var data = Json.parse(file.content);

            for (field in Reflect.fields(data)) {
                castData.set(field, cast Reflect.field(data, field));
            }

            _translations.set(language, castData);
        }
    }

    public function setLang(lang: Language) {
        _language = lang;
    }

    public function g(str: String, ?vars: Array<String>, variant: Int = 0): String {
        var ret = _translations.get(cast _language).get(str)[variant];

        if (vars != null) {
            for (replacement in vars) {
                ret = ~/%%/.replace(ret, replacement);
            }
        }

        return ret;
    }
}
