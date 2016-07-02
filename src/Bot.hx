package ;

import model.Core;
import discordhx.client.Client;
import event.ProcessEventHandler;
import event.ClientEventHandler;
import utils.Logger;
import config.AuthDetails;
import nodejs.NodeJS;

class Bot {
    public static var instance(get, null):Bot;

    private static var _instance:Bot;

    public static function main() {
        Logger.info('Launching application...');
        _instance = new Bot();
    }

    public static function get_instance() {
        if (_instance == null) {
            _instance = new Bot();
        }

        return _instance;
    }

    private function new() {
        Logger.info('Application launched. Initializing...');

        var client:Client = new Client();
        var clientEventHandler = new ClientEventHandler(client);
        var processEventHandler = new ProcessEventHandler(NodeJS.process);

        Core.initialize(client);
        Logger.info('Logging in...');
        Core.instance.connect();
    }
}
