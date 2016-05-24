package event;

import external.discord.client.Client;
import nodejs.NodeJS;
import utils.Logger;
import nodejs.Process;
import external.nodejs.ProcessEventType;

class ProcessEventHandler extends EventHandler<Process> {
    private override function process(): Void {
        _eventEmitter.on(cast ProcessEventType.UNCAUGHT_EXCEPTION, uncaughtExceptionHandler);
        _eventEmitter.on(cast ProcessEventType.SIGINT, signalInterruptionHandler);
    }

    private function uncaughtExceptionHandler(e: Dynamic) {
        Logger.exception(e.stack);

        if (NodeJS.global.client != null) {
            var client: Client = cast NodeJS.global.client;

            client.logout();
        }
    }

    private function signalInterruptionHandler() {
        Logger.end();
        NodeJS.process.exit(0);
    }
}
