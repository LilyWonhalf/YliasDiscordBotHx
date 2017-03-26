package yliasdiscordbothx.utils;

import js.Promise;
import nodejs.http.HTTPClientRequest;
import nodejs.http.ServerResponse;
import nodejs.http.HTTPS;
import nodejs.http.HTTP;

class HttpQuery {
    public var secured: Bool;
    public var host: String;
    public var path: String;
    public var method: HTTPMethod;
    public var data: String;
    public var headers: Map<String, String>;

    public function new(?host: String, ?path: String) {
        if (host != null) {
            this.host = host;
        }

        if (path != null) {
            this.path = path;
        }

        secured = true;
        method = cast HTTPMethod.Get;
        data = null;
        headers = null;
    }

    public function send(): Promise<String> {
        return new Promise<String>(function (resolve: String->Void, reject: Dynamic->Void) {
            var port = 80;
            var contentLength = 0;

            if (data != null) {
                contentLength = data.length;
            }

            if (secured) {
                port = 443;
            }

            var options = {
                host: host,
                port: port,
                path: path,
                method: method,
                headers: {
                    'User-Agent': 'YliasDiscordBotHx/2.0 (by ElianWonhalf)',
                    'Content-Type': 'application/json',
                    'Content-Length': contentLength
                }
            };

            if (headers != null) {
                for (header in headers.keys()) {
                    Reflect.setField(options.headers, header, headers.get(header));
                }
            }

            var req: HTTPClientRequest;

            if (secured) {
                req = HTTPS.request(cast options, function (res: ServerResponse) {
                    var output = '';

                    res.on('data', function (chunck) {
                        output += chunck;
                    });

                    res.on('end', function() {
                        resolve(output);
                    });
                });
            } else {
                req = HTTP.request(cast options, function (res: ServerResponse) {
                    var output = '';

                    res.on('data', function (chunck) {
                        output += chunck;
                    });

                    res.on('end', function() {
                        resolve(output);
                    });
                });
            }

            if (data != null) {
                req.write(data);
            }

            req.end();
        });
    }
}
