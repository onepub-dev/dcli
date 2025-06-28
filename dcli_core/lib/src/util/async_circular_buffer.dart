/*
 * Copyright (c) 2025 S. Brett Sutton 2022+
 *
 * This software is licensed under the MIT License.
 * SPDX-License-Identifier: MIT
 */

import 'dart:async';

import 'dart:math';

/// A [AsyncCircularBuffer] with a fixed capacity supporting
/// all [List] operations
///
/// ```dart
/// final buffer = CircularBuffer<int>(3)..add(1)..add(2);
/// print(buffer.length); // 2
/// print(buffer.first); // 1
/// print(buffer.isFilled); // false
/// print(buffer.isUnfilled); // true
///
/// buffer.add(3);
/// print(buffer.length); // 3
/// print(buffer.isFilled); // true
/// print(buffer.isUnfilled); // false
///
/// buffer.add(4);
/// print(buffer.first); // 4
/// ```
class AsyncCircularBuffer<T>
// with IterableMixin<Future<T>>
// implements Iterable<Future<T>>
// with ListMixin<T>
{
  /// Creates a [AsyncCircularBuffer] with a `capacity`
  AsyncCircularBuffer(int capacity)
      : assert(capacity > 1, 'capacity must be at least 1'),
        _capacity = capacity,
        _buf = [],
        _end = -1,
        _count = 0,
        _threshold = max(1, (0.2 * capacity).toInt());

  /// Creates a [AsyncCircularBuffer] based on another `list`
  AsyncCircularBuffer.of(List<T> list, [int? capacity])
      : assert(capacity == null || capacity >= list.length,
            'capacity must be null or greater than list'),
        _capacity = capacity ?? list.length,
        _buf = [...list],
        _end = list.length - 1,
        _count = list.length,
        _threshold = max(1, 0.2 * (capacity ?? list.length) as int);

  final List<T> _buf;
  final int _capacity;

  final int _threshold;

  /// Space is available in the buffer.
  /// Each time the buffer fills we won't mark
  /// space available until the buffer has
  /// bee read down to the [_threshold].
  var _spaceAvailable = Completer<bool>();

  /// Elements are available in the buffer.
  var _elementsAvailable = Completer<bool>();

  /// indicates that the buffer has been closed by the provider.
  /// We complete the future once the buffer closes.
  final _closed = Completer<bool>();

  /// indicates that the buffer has been closed and
  /// all elements read.
  final _done = Completer<bool>();

  int _start = 0;
  int _end;
  int _count;

  /// Completes when the buffer has been closed
  /// and all elements read.
  Future<bool> get isDone => _done.future;

  /// The [AsyncCircularBuffer] is `reset`
  void reset() {
    if (_closed.isCompleted) {
      throw BadStateException('Buffer has been closed');
    }
    _start = 0;
    _end = -1;
    _count = 0;

    _spaceAvailable.complete(true);
    _elementsAvailable = Completer<bool>();
  }

  /// Close the circular buffer indicating no more values will be added.
  /// Calls to get will throw with an underflow exception if called
  /// when there are no more elements in the buffer and [close] has bee
  /// called.
  void close() {
    if (!_closed.isCompleted) {
      _closed.complete(true);
    }

    if (_isEmpty && !_done.isCompleted) {
      _done.complete(true);
    }
  }

  /// Adds [element] to the buffer.
  /// This method will wait if the buffer is full.
  /// An [BadStateException]  will be thrown if the buffer
  /// has been closed.
  Future<void> add(T element) async {
    if (_closed.isCompleted) {
      throw BadStateException('Buffer has been closed');
    }
    if (isFilled) {
      /// wait until we have more space available.
      /// If the buffer was closed after we start waiting
      /// we still allow this last add to continue.
      await _spaceAvailable.future;
    }

    // Adding the next value
    _end++;
    if (_end == _capacity) {
      _end = 0;
    }

    if (_buf.length == _capacity) {
      /// [_buf] is full grown so add at [_end]
      _buf[_end] = element;
    } else {
      /// [_buf] isn't full grown yet so grow it.
      _buf.add(element);
    }
    _count++;

    if (isFilled) {
      /// we are full so block add
      _spaceAvailable = Completer<bool>();
    }
    // _incStart();
    if (!_elementsAvailable.isCompleted) {
      /// we now have elements available.
      _elementsAvailable.complete(true);
    }
  }

  void _incStart() {
    _start++;
    if (_start == _capacity) {
      _start = 0;
    }
  }

  /// Returns the next element in the buffer.
  /// If the buffer is closed and empty then returns null.
  /// If the buffer is empty [get] waits until a new
  /// element arrives before returning.
  Future<T> get() async {
    if (_isEmpty) {
      if (_closed.isCompleted) {
        return throw UnderflowException();
      } else {
        await Future.any<bool>([_elementsAvailable.future, _closed.future]);
        if (_closed.isCompleted && _isEmpty) {
          return throw UnderflowException();
        }
      }
    }
    final element = this[0];
    _incStart();
    _count--;

    /// we have less items than threshold so allow more
    /// items to be added.
    if (length < _threshold && !_spaceAvailable.isCompleted) {
      _spaceAvailable.complete(true);
    }

    if (_isEmpty) {
      /// no elements available so block futher gets.
      _elementsAvailable = Completer<bool>();

      /// we are closed and empty.
      if (_closed.isCompleted) {
        _done.complete(true);
      }
    }

    return element;
  }

  /// iterator over the list of elements.
  Iterator<Future<T>> get iterator => _CircularBufferIterator(this);

  /// Number of elements of [AsyncCircularBuffer]
  int get length => _count;

  /// Maximum number of elements of [AsyncCircularBuffer]
  int get capacity => _capacity;

  /// The [AsyncCircularBuffer] `isFilled`  if the `length`
  /// is equal to the `capacity`
  bool get isFilled => _count == _capacity;

  /// The [AsyncCircularBuffer] `isUnfilled`  if the `length` is
  /// is less than the `capacity`
  bool get isUnfilled => _count < _capacity;

  /// True if the buffer is closed and will not
  /// accept any more calls to [add]
  bool get isClosed => _closed.isCompleted;

  bool get _isEmpty => _count == 0;

  bool get _isNotEmpty => _count > 0;

  /// Access element at [index]
  T operator [](int index) {
    if (index >= 0 && index < _count) {
      return _buf[(_start + index) % _buf.length]!;
    }
    throw RangeError.index(index, this);
  }

  /// Assign an element at [index]
  void operator []=(int index, T value) {
    if (index >= 0 && index < _count) {
      _buf[(_start + index) % _buf.length] = value;
    } else {
      throw RangeError.index(index, this);
    }
  }

  /// Returns a stream of the contained elements.
  Stream<T> stream() async* {
    try {
      while (!_closed.isCompleted) {
        final element = await get();
        yield element;
      }
    } on UnderflowException catch (_) {
      // if we are closed whilst waiting for get we get an [UnderFlowException]
      // Nothing to do here as the stream will just end naturally.
    }
  }

  /// The `length` mutation is forbidden
  set length(int newLength) {
    throw UnsupportedError('Cannot resize immutable CircularBuffer.');
  }

  @override
  String toString() {
    final sb = StringBuffer()..write('[');
    for (var i = 0; i < length; i++) {
      if (sb.length != 1) {
        sb.write(',');
      }
      sb.write('${this[i]}');
    }
    sb.write(']');
    return sb.toString();
  }

  /// empties the buffer, discarding all elements.
  Future<void> drain() async {
    while (_isNotEmpty) {
      await get();
    }
  }
}

class _CircularBufferIterator<T> implements Iterator<Future<T>> {
  ///
  _CircularBufferIterator(this._buffer);
  // Iterate over odd numbers
  final AsyncCircularBuffer<T> _buffer;

  ///
  @override
  bool moveNext() => !(_buffer._closed.isCompleted && _buffer._isEmpty);

  /// will throw an [UnderflowException] if the buffer is
  /// empty and closed.
  @override
  Future<T> get current async {
    final element = await _buffer.get();

    if (element == null) {
      throw UnderflowException();
    }

    return element;
  }
}

/// An attempt was made to access the buffer when it was closed.
class BadStateException implements Exception {
  /// An attempt was made to access the buffer when it was closed.
  BadStateException(this.message);

  /// The message.
  String message;

  @override
  String toString() => message;
}

/// An attempt was made to access the buffer when
/// it was closed and empty.
class UnderflowException implements Exception {
  /// An attempt was made to access the buffer when
  /// it was closed and empty.
  UnderflowException();

  /// the error message.
  String get message => 'The buffer is closed and empty';
  @override
  String toString() => message;
}
