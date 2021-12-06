import 'dart:async';

import 'dart:collection';

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
    with IterableMixin<Future<T>>
    implements Iterable<Future<T>>
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

  /// indicates that the buffer has been closed by the provider.
  /// We complete the future once the buffer closes.
  final _closed = Completer<bool>();

  int _start = 0;
  int _end;
  int _count;

  /// The [AsyncCircularBuffer] is `reset`
  void reset() {
    _start = 0;
    _end = -1;
    _count = 0;
  }

  var _spaceAvailable = Completer<bool>();

  var _elementsAvailable = Completer<bool>();

  /// Close the circular buffer indicating no more values will be added.
  /// Calls to get will throw with an underflow exception if called
  /// when there are no more elements in the buffer and [close] has bee
  /// called.
  void close() => _closed.complete(true);

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
    }

    return element;
  }

  Iterator<Future<T>> get iterator => CircularBufferIterator(this);

  /// Number of elements of [AsyncCircularBuffer]
  @override
  int get length => _count;

  /// Maximum number of elements of [AsyncCircularBuffer]
  int get capacity => _capacity;

  /// The [AsyncCircularBuffer] `isFilled`  if the `length`
  /// is equal to the `capacity`
  bool get isFilled => _count == _capacity;

  /// The [AsyncCircularBuffer] `isUnfilled`  if the `length` is
  /// is less than the `capacity`
  bool get isUnfilled => _count < _capacity;

  bool get _isEmpty => _count == 0;

  bool get _isNotEmpty => _count > 0;

  @override
  T operator [](int index) {
    if (index >= 0 && index < _count) {
      return _buf[(_start + index) % _buf.length]!;
    }
    throw RangeError.index(index, this);
  }

  @override
  void operator []=(int index, T value) {
    if (index >= 0 && index < _count) {
      _buf[(_start + index) % _buf.length] = value;
    } else {
      throw RangeError.index(index, this);
    }
  }

  /// The `length` mutation is forbidden
  @override
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
  void drain() {
    while (_isNotEmpty) {
      get();
    }
  }
}

class CircularBufferIterator<T> implements Iterator<Future<T>> {
  ///
  CircularBufferIterator(this._buffer);
  // Iterate over odd numbers
  AsyncCircularBuffer<T> _buffer;

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

class BadStateException implements Exception {
  BadStateException(this.message);

  String message;

  String toString() => message;
}

class UnderflowException implements Exception {
  UnderflowException();

  String get message => 'The buffer is closed and empty';
  @override
  String toString() => message;
}
