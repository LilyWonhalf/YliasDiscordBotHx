package external.htmlentities;

@:native('(require("html-entities")).Html5Entities')
extern class Html5Entities {
    public function new(): Void;
    public function decode(content: String): String;
}
