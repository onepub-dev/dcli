import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  test('simple run', () {
    withTempFile((testFile) {
      'touch $testFile'.run;
    });
  });
}
