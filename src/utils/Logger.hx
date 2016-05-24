package utils;

class Logger {
    private static var prefix = Date.now().toString() + ' | ';

    public static function info(msg: String) {
        trace(prefix + 'INFO | ' + msg);
    }

    public static function error(msg: String) {
        trace(prefix + 'ERROR | ' + msg);
    }

    public static function warning(msg: String) {
        trace(prefix + 'WARNING | ' + msg);
    }

    public static function notice(msg: String) {
        trace(prefix + 'NOTICE | ' + msg);
    }

    public static function important(msg: String) {
        trace('---------------------');
        trace(msg);
        trace('---------------------');
    }

    public static function exception(exception: Dynamic) {
        trace('---------------------');
        trace('Ugh. What... What happenned?');
        trace(exception);
        trace('---------------------');
    }

    public static function debug(element: Dynamic) {
        trace('---------------------');
        trace('Wait, I wanna see this one more clearly...');
        trace(element);
        trace('---------------------');
    }

    public static function end() {
        trace('---------------------');
        trace('You really want me to die, don\'t you? Fine.');
    }
}
