/// a circular buffer.
class CircularBuffer<T> {
  List<T> _buf;
  int _start;
  int _end;
  int _count;
  int capacity;

  /// create a circulare buffer with the ability
  /// to store at most [capacity] items.
  CircularBuffer(int capacity) {
    _buf = <T>[];
    reset();
  }

  /// empty the buffer.
  void reset() {
    _start = 0;
    _end = -1;
    _count = 0;
  }

  /// insert a value at the curent location.
  void insert(T el) async {
    // Inserting the next value
    _end++;
    if (_end == capacity) {
      _end = 0;
    }
    _buf[_end] = el;

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

  /// the current lenght of the buffer
  int get len => _count;

  /// the max capacity of the buffer.
  int get cap => capacity;

  /// true if the buffer is filled
  bool get filled => (_count == capacity);

  /// false if the buffer is not a capacity.
  bool get unfilled => (_count < capacity);

  /// Allows you to iterate over the contents of the buffer
  /// The [action] callback is called for each item in the
  /// buffer.
  void forEach(void Function(T) action) {
    for (var i = _start; i < _start + _count; i++) {
      var val = _buf[i % len];
      action(val);
    }
  }
}
