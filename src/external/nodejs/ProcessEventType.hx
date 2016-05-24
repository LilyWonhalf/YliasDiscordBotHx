package external.nodejs;

@:enum
abstract ProcessEventType(String) {
    var BEFORE_EXIT = 'beforeExit';
    var EXIT = 'exit';
    var MESSAGE = 'message';
    var REJECTION_HANDLED = 'rejectionHandled';
    var UNCAUGHT_EXCEPTION = 'uncaughtException';
    var UNHANDLED_REJECTION = 'unhandledRejection';
    var SIGUSR1 = 'SIGUSR1';
    var SIGTERM = 'SIGTERM';
    var SIGINT = 'SIGINT';
    var SIGPIPE = 'SIGPIPE';
    var SIGHUP = 'SIGHUP';
    var SIGBREAK = 'SIGBREAK';
    var SIGWINCH = 'SIGWINCH';
}
