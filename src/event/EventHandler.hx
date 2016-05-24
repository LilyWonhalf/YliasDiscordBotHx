package event;

class EventHandler<T> {
    private var _eventEmitter: T;

    public function new(eventEmitter: T) {
        _eventEmitter = eventEmitter;
        process();
    }

    private function process(): Void {

    }
}
