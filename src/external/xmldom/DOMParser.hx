package external.xmldom;

import js.html.Document;

@:native("(require('xmldom')).DOMParser")
extern class DOMParser {
    public function new(): Void;
    public function parseFromString(source: String, mimeType: String): Document;
}
