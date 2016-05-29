package translations;

import haxe.Json;
import system.FileSystem;
import translations.LangCenter.Lang;

class Translator {
    private var _translations: Map<String, Map<String, Array<String>>>;

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

    public function getTranslation(lang: Lang, str: String, ?vars: Array<String>, variant: Int = 0): String {
        var ret = _translations.get(cast lang).get(str)[variant];

        if (vars != null) {
            for (replacement in vars) {
                ret = ~/%%/.replace(ret, replacement);
            }
        }

        return ret;
    }
}
