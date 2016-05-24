package system;

import haxe.macro.Context;

class FileSystem {
    macro public static function json(path: String) {
        var resolvedPath = Context.resolvePath(path);
        var value = sys.io.File.getContent(resolvedPath);
        var json = haxe.Json.parse(value);

        return macro $v{json};
    }

    macro public static function getFileListInFolder(path: String) {
        var resolvedPath = Context.resolvePath(path);
        var files = sys.FileSystem.readDirectory(resolvedPath);

        return macro $v{files};
    }

    macro public static function getFilesInFolder(path: String, ?format: String) {
        var resolvedPath = Context.resolvePath(path);
        var files = sys.FileSystem.readDirectory(resolvedPath);
        var fileContents = new Array<FileInfo>();

        for (file in files) {
            if (format != null && file.indexOf("." + format) > -1) {
                var s:String = ${path} + "/" + ${file};

                var resolvedPath = Context.resolvePath(s);
                var value = sys.io.File.getContent(resolvedPath);

                fileContents.push({
                    path: path,
                    name: file,
                    content: value
                });
            }
        }

        return macro {
            $v{fileContents};
        }
    }
}

typedef FileInfo = {
    path:String,
    name:String,
    content:String
}
