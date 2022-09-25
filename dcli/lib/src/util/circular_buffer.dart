/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

/// a circular buffer.
class CircularBuffer<T> {
  /// create a circulare buffer with the ability
  /// to store at most [capacity] items.
  CircularBuffer(this.capacity) {
    _buf = <T>[];
    reset();
  }

  CircularBuffer.fromList(List<T> initialList) {
    reset();
    _buf = [...initialList];
    capacity = initialList.length;
    _count = capacity;
  }

  late List<T> _buf;
  late int _start;
  late int _end;
  late int _count;

  /// The no. of elements the buffer can hold.
  /// Once this limit is reach the buffer rolls over to the start of the buffer.
  late final int capacity;

  /// empty the buffer.
  void reset() {
    _start = 0;
    _end = -1;
    _count = 0;
  }

  /// insert a value at the curent location.
  void add(T el) {
    // Inserting the next value
    _end++;
    if (_end == capacity) {
      _end = 0;
    }
    if (_end >= _buf.length) {
      _buf.add(el);
    } else {
      _buf[_end] = el;
    }

    // updating the start
    if (_count < capacity) {
      _count++;
      return;
    }

    _start++;
    if (_start == capacity) {
      _start = 0;
    }
  }

  /// the first value in the buffer
  T get start => _buf[_start];

  /// the last value in the buffer.
  T get end => _buf[_end];

  /// the current length of the buffer
  int? get len => _count;

  /// the max capacity of the buffer.
  int get cap => capacity;

  bool get isEmpty => _count == 0;

  /// true if the buffer is filled
  bool get isFilled => _count == capacity;

  /// false if the buffer is not a capacity.
  bool get hasRoom => _count < capacity;

  /// Allows you to iterate over the contents of the buffer
  /// The [action] callback is called for each item in the
  /// buffer.
  void forEach(void Function(T) action) {
    for (var i = _start; i < _start + _count; i++) {
      final val = _buf[i % len!];
      action(val);
    }
  }

  /// returns the next value in the buffer
  /// incrementing the current location;
  T next() {
    if (isEmpty) {
      throw BadStateError('The buffer is empty');
    }
    final next = start;
    _start++;
    if (_start == capacity) {
      _start = 0;
    }
    _count--;
    return next;
  }
}

class BadStateError extends Error {
  BadStateError(this.message);
  String message;
}
