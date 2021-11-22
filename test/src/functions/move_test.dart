import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('move ...', () async {
    withTempDir((dir) {
      touch('one.txt', create: true);
      touch('two.txt', create: true);

      expect(() => move('one.txt', 'two.txt'),
          equals(throwsA(isA<MoveException>())));

      move('one.txt', 'two.txt', overwrite: true);
      expect(!exists('one.txt'), isTrue);
      expect(exists('two.txt'), isTrue);
    });
  });
}
