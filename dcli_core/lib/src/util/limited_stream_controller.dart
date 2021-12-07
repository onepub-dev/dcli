import 'dart:async';

import 'async_circular_buffer.dart';

class LimitedStreamController<T> implements StreamController<T> {
  /// Creates a new [LazyStreamController] that will be a non-broadcast
  /// controller.
  LimitedStreamController(int limit,
      {void Function()? onListen, void Function()? onCancel, bool sync = false})
      : _streamController = StreamController<T>(
            onListen: onListen, onCancel: onCancel, sync: sync),
        _buffer = AsyncCircularBuffer(limit);

  final AsyncCircularBuffer<T> _buffer;

  final StreamController<T> _streamController;

  /// Returns the no. of elements waiting in the stream.
  int get length => _buffer.length;

  @override
  bool get isClosed => _streamController.isClosed;

  @override
  bool get hasListener => _streamController.hasListener;

  @override
  bool get isPaused => _streamController.isPaused;

  @Deprecated('Use asyncAdd')
  @override
  void add(T event) {
    throw UnsupportedError('Use asyncAdd');
  }

  ///
  Future<void> asyncAdd(T event) async {
    await _buffer.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _streamController.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<T> source, {bool? cancelOnError = true}) {
    throw UnsupportedError('Use asyncAdd');
    // return _streamController.addStream(source, cancelOnError: cancelOnError);
  }

  @override
  Future<dynamic> close() {
    _buffer.close();
    return _streamController.close();
  }

  @override
  Future get done => _streamController.done;

  // @override
  // StreamSink<T> get sink => _streamController.sink;

  @override
  StreamSink<T> get sink => throw UnsupportedError('Use asyncAdd');

  @override
  // ignore: prefer_expression_function_bodies
  Stream<T> get stream {
    return _buffer.stream();
    // return _streamController.stream;
  }

  @override
  set onListen(void Function()? onListenHandler) {
    _streamController.onListen = onListenHandler;
  }

  @override
  ControllerCallback? get onListen => _streamController.onListen;

  @override
  set onPause(void Function()? onPauseHandler) {
    _streamController.onPause = onPauseHandler;
  }

  @override
  ControllerCallback? get onPause => _streamController.onPause;

  @override
  set onResume(void Function()? onResumeHandler) {
    _streamController.onResume = onResumeHandler;
  }

  @override
  ControllerCallback? get onResume => _streamController.onResume;

  @override
  set onCancel(void Function()? onCancelHandler) {
    _streamController.onCancel = onCancelHandler;
  }

  @override
  ControllerCancelCallback? get onCancel => _streamController.onCancel;
}
