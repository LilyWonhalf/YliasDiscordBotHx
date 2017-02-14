package yliasdiscordbothx.event;

class EventHandler<T> {
    private var eventEmitter: T;

    public function new(eventEmitter: T) {
        this.eventEmitter = eventEmitter;
        process();
    }

    private function process(): Void {}
}
