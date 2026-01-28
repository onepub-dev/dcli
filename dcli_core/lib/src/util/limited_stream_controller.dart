/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:async';

/// A specialized StreamController that limits the no.
/// of elements that can be in the stream.
class LimitedStreamController<T> implements StreamController<T> {
  /// Creates a new [LimitedStreamController] that limits the no.
  /// of elements that can be in the queue.
  LimitedStreamController(this._limit,
      {void Function()? onListen, void Function()? onCancel, bool sync = false})
      : _streamController = StreamController<T>(
            onListen: onListen, onCancel: onCancel, sync: sync);

  final StreamController<T> _streamController;

  final int _limit;

  /// Tracks the no. of elements in the stream.
  var _count = 0;

  /// Used to indicate when the stream is full
  var _spaceAvailable = Completer<bool>();

  /// Returns the no. of elements waiting in the stream.
  int get length => _count; // _buffer.length;

  @override
  bool get isClosed => _streamController.isClosed;

  @override
  bool get hasListener => _streamController.hasListener;

  @override
  bool get isPaused => _streamController.isPaused;

  /// @Throwing(UnsupportedError)
  @Deprecated('Use asyncAdd')
  @override
  void add(T event) {
    throw UnsupportedError('Use asyncAdd');
  }

  /// Add an event to the stream. If the
  /// stream is full then this method will
  /// wait until there is room.
  Future<void> asyncAdd(T event) async {
    if (_count >= _limit) {
      await _spaceAvailable.future;
    }
    _count++;
    _streamController.add(event);

    if (_count >= _limit) {
      _spaceAvailable = Completer<bool>();
    }
  }

  @override
  Stream<T> get stream async* {
    /// return _buffer.stream();
    await for (final element in _streamController.stream) {
      _count--;

      if (_count < _limit && !_spaceAvailable.isCompleted) {
        /// notify that we have space available
        _spaceAvailable.complete(true);
      }
      yield element;
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _streamController.addError(error, stackTrace);
  }

  /// @Throwing(UnsupportedError)
  @override
  Future<bool> addStream(Stream<T> source, {bool? cancelOnError = true}) {
    throw UnsupportedError('Use asyncAdd');
  }

  @override
  Future<dynamic> close() => _streamController.close();

  @override
  Future<dynamic> get done => _streamController.done;

  /// @Throwing(UnsupportedError)
  @override
  StreamSink<T> get sink => throw UnsupportedError('Use asyncAdd');

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
