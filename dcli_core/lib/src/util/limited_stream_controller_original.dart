import 'dart:async';

import 'async_circular_buffer.dart';

///
class LimitedStreamControllerOriginal<T> implements StreamController<T> {
  ///
  LimitedStreamControllerOriginal(int limit) : _buffer = AsyncCircularBuffer(limit);

  final AsyncCircularBuffer<T> _buffer;

  @override
  late FutureOr<void> Function()? onCancel;

  @override
  late void Function()? onListen;

  @override
  late void Function()? onPause;

  @override
  late void Function()? onResume;

  /// Returns the no. of elements waiting in the stream.
  int get length => _buffer.length;

  @override
  void add(T event) {
    throw UnsupportedError('Use asyncAdd');
  }

  ///
  Future<void> asyncAdd(T event) async => _buffer.add(event);

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    throw UnsupportedError('Use asyncAdd');
  }

  @override
  Future addStream(Stream<T> source, {bool? cancelOnError}) =>
      throw UnsupportedError('Use asyncAdd');

  @override
  Future<void> close() {
    _buffer.close();
    return Future<void>.value();
  }

  final bool _paused = false;
  @override
  Future get done => _buffer.isDone;

  @override
  bool get hasListener => throw UnsupportedError('sorry');

  @override
  bool get isClosed => _buffer.isClosed;

  @override
  bool get isPaused => _paused;

  @override
  StreamSink<T> get sink => throw UnsupportedError('Use asyncAdd');

  @override
  Stream<T> get stream => _buffer.stream();
}
