import 'package:dcli_core/dcli_core.dart';
import 'package:test/test.dart';

void main() {
  test('head ...', () async {
    await withTempFile((pathToFile) async {
      await withOpenLineFile(pathToFile, (file) async {
        for (var i = 0; i < 100; i++) {
          await file.write('Line No. $i');
        }
      });
      // var stream = await head(pathToFile, 10);
    });
  });
}
