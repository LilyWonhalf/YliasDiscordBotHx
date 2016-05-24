package utils;

class ArrayUtils {
    public static function random<T>(arr: Array<T>): T {
        var ret: T = null;

        if (arr.length > 0) {
            ret = arr[Math.floor(Math.random() * arr.length)];
        }

        return ret;
    }

    public static function randomSearch(arr: Array<String>, words: Array<String>) {
        var ret: String = null;

        if (words.length > 0) {
            arr = arr.filter(function (element: String) {
                var keep = true;

                for (word in words) {
                    keep = keep && element.toLowerCase().indexOf(word.toLowerCase()) > -1;

                    if (!keep) {
                        break;
                    }
                }

                return keep;
            });
        }

        ret = random(arr);

        return ret;
    }
}
