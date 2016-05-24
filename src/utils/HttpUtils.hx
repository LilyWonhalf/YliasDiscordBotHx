package utils;

import nodejs.http.HTTPClientRequest;
import nodejs.http.ServerResponse;
import nodejs.http.HTTPS;
import nodejs.http.HTTP;

class HttpUtils {
    public static function query(secured: Bool, host: String, path: String, method: HTTPMethod, callback: String->Void): Void {
        var port = 80;

        if (secured) {
            port = 443;
        }

        var options = {
            host: host,
            port: port,
            path: path,
            method: method,
            headers: {
                'User-Agent': 'YliasDiscordBotHx/1.0 (by ElianWonhalf)'
            }
        };

        var req: HTTPClientRequest;

        if (secured) {
            req = HTTPS.request(cast options, function (res: ServerResponse) {
                var output = '';

                res.on('data', function (chunck) {
                    output += chunck;
                });

                res.on('end', function() {
                    callback(output);
                });
            });
        } else {
            req = HTTP.request(cast options, function (res: ServerResponse) {
                var output = '';

                res.on('data', function (chunck) {
                    output += chunck;
                });

                res.on('end', function() {
                    callback(output);
                });
            });
        }

        req.end();
    }
}
