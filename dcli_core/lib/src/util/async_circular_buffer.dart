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
class AsyncCircularBuffer<T> with ListMixin<T> {
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

  final _elementsAvailable = Completer<bool>();

  @override
  Future<void> add(T element) async {
    if (isFilled) {
      /// wait until we have more space available.
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

  ///
  Future<T> get() async {
    if (isEmpty) {
      await _elementsAvailable.future;
    }
    final element = this[0];
    _incStart();
    _count--;

    /// we have less items than threshold so allow more
    /// items to be added.
    if (length < _threshold && !_spaceAvailable.isCompleted) {
      _spaceAvailable.complete(true);
    }

    if (isEmpty) {
      /// no space available so block add.
      _spaceAvailable = Completer<bool>();
    }

    return element;
  }

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

  /// empties the buffer, discarding all elements.
  void drain() {
    while (!isEmpty) {
      get();
    }
  }
}
