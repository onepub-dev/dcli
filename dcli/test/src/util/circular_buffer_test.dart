import 'package:dcli/src/util/circular_buffer.dart';
import 'package:test/test.dart';

void main() {
  test('circular buffer - underflow', () async {
    final buffer = CircularBuffer<String>(3);

    expect(buffer.isEmpty, isTrue);
    expect(buffer.next, throwsA(isA<BadStateError>()));
  });

  test('circular buffer - next', () async {
    final buffer = CircularBuffer<String>(3)..add('one');

    expect(buffer.next(), 'one');
  });

  test('circular buffer - overflow', () async {
    final buffer = CircularBuffer<String>(3)
      ..add('one')
      ..add('one')
      ..add('one')
      ..add('four');

    expect(buffer.isFilled, isTrue);
    expect(buffer.hasRoom, isFalse);
    expect(buffer.isEmpty, isFalse);
    expect(buffer.next(), 'one');
    expect(buffer.next(), 'one');
    expect(buffer.next(), 'four');

    expect(buffer.isEmpty, isTrue);
    expect(buffer.isFilled, isFalse);
    expect(buffer.hasRoom, isTrue);
  });
}
