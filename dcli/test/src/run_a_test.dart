import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(DeleteException)
/// @Throwing(TouchException)
void main() {
  test('simple run', () async {
    await withTempFileAsync((testFile) async {
      'touch $testFile'.run;
    });
  });
}
