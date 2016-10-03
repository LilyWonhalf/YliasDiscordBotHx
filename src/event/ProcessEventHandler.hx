package event;

import haxe.Timer;
import model.Db;
import model.Core;
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
        Core.instance.disconnect();

        Timer.delay(function () {
            Core.instance.connect();
        }, 100);
    }

    private function signalInterruptionHandler() {
        Core.instance.disconnect();
        Db.instance.close();
        Logger.end();
        NodeJS.process.exit(0);
    }
}
