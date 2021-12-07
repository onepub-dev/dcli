import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('tail with more than required', () async {
    withTempFile((tmp) {
      for (var i = 0; i < 20; i++) {
        tmp.append('line $i');
      }
      expect(tail(tmp, 1).toList().first, 'line 19');
    });
  });

  test('tail with less than required', () async {
    withTempFile((tmp) {
      for (var i = 0; i < 20; i++) {
        tmp.append('line $i');
      }

      final list = tail(tmp, 40).toList();
      expect(list.length == 20, isTrue);
      expect(list.last, 'line 19');
    });
  });

  test('tail with godlocks zone', () async {
    withTempFile((tmp) {
      for (var i = 0; i < 20; i++) {
        tmp.append('line $i');
      }

      final list = tail(tmp, 20).toList();
      expect(list.length == 20, isTrue);
      expect(list.last, 'line 19');
    });
  });

  test('tail with none', () async {
    withTempFile((tmp) {
      touch(tmp);

      final list = tail(tmp, 20).toList();
      expect(list.isEmpty, isTrue);
    });
  });
}
