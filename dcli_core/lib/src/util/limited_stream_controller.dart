import 'dart:async';

import 'async_circular_buffer.dart';

// Stream<T> _stream<T>(AsyncCircularBuffer<T> buff) async* {
//   try {
//   await for  (final element in buff) {
//     yield await element;
//   }
//   } on UnderflowException catch (_)
//   {
//     /// this is expected as buff.current throws to indicate that
//     /// the buf is empty and closed.
//     /// This is done to overcome the fact that a
//   }
// }

/// A stream that tightly controls the producer to ensure that the producer
/// doesn't get significantly ahead of the consumer.
///
/// If you have a slow consumer and a fast producer you can get situations where
/// the producer generates large nos of unprocessed events that need to be
///  buffered in the stream which consumes large amounts of memory.
///
/// The [LimitedStream] aims to reduce the amount of buffering that occurs in
/// the stream by tightly controlling the producer.
// class LimitedStream<T> extends Stream<T> {
//   ///
//   LimitedStream(this._buffer, this._controller);

//   ///
//   final AsyncCircularBuffer<T> _buffer;

//   final StreamController<T> _controller;

//   ///
//   @override
//   StreamSubscription<T> listen(void Function(T event)? onData,
//       {Function? onError, void Function()? onDone, bool? cancelOnError})  {

//    final done = Completer<bool>();
//     late final StreamSubscription<T> sub;
//     sub = _controller.stream.listen((e) async {
//       sub.pause();
//       final element = await _buffer.get();
//       if (onData != null) {
//         onData(element);
//       }
//       sub.resume();
//     }, onError: onError, onDone: () {

//       if (onDone != null){
//       onDone();
//       }
//       done.complete(true);

//     }, cancelOnError: cancelOnError);

//     await done.future;
//     // ignore: cascade_invocations
//     sub.cancel();
//     return sub;
//   }
// }

///
class LimitedStreamController<T> implements StreamController<T> {
  ///
  LimitedStreamController(int limit) : _buffer = AsyncCircularBuffer(limit);

  final _controller = StreamController<T>();
  final AsyncCircularBuffer<T> _buffer;

  @override
  late FutureOr<void> Function()? onCancel = _controller.onCancel;

  @override
  late void Function()? onListen = _controller.onListen;

  @override
  late void Function()? onPause = _controller.onPause;

  @override
  late void Function()? onResume = _controller.onResume;

  int get length => _buffer.length;

  @override
  void add(T event) {
    throw UnsupportedError('Use asyncAdd');
  }

  ///
  Future<void> asyncAdd(T event) async {
    _controller.sink.add(event);
    return _buffer.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _controller.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<T> source, {bool? cancelOnError}) =>
      _controller.addStream(source, cancelOnError: cancelOnError);

  @override
  Future close() {
    _buffer.close();
    return _controller.close();
  }

  @override
  Future get done => _controller.done;

  @override
  bool get hasListener => _controller.hasListener;

  @override
  bool get isClosed => _controller.isClosed;

  @override
  bool get isPaused => _controller.isPaused;

  @override
  StreamSink<T> get sink => throw UnsupportedError('Use asyncAdd');

  @override
  Stream<T> get stream => _buffer.stream();
}
