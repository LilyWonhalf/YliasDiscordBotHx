package yliasdiscordbothx.external.imgflipper;

@:native("(require('imgflipper'))")
extern class Imgflipper {
    public function new(username: String, password: String): Void;
    public function generateMeme(type: Int, top: String, bottom: String, callback: Dynamic->String->Void): Void;
}
