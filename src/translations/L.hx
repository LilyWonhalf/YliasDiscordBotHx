package translations;

class L {
    public static var a(get, null): L;

    private static var _instance: L;

    public var n(get, null): Translator;

    private var _lang: Language;
    private var _translator: Translator;

    public static function get_a(): L {
        if (_instance == null) {
            _instance = new L();
        }

        return _instance;
    }

    public function setLang(lang: Language): Void {
        _lang = lang;
        _translator.setLang(_lang);
    }

    public function getLang(): Language {
        return _lang;
    }

    public function get_n(): Translator {
        return _translator;
    }

    private function new() {
        _translator = new Translator();
        setLang(Language.fr_FR);
    }
}

@:enum
abstract Language(String) {
    var fr_FR = 'fr_FR';
    var en_GB = 'en_GB';
}