import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('tail ...', () async {
    withTempFile((tmp) {
      for (var i = 0; i < 20; i++) {
        tmp.append('line $i');
      }
      expect(tail(tmp, 1).toList().first, 'line 19');
    });
  });
}
