import 'package:dcli/src/process/process/settings.dart';
import 'package:dcli/src/process/process/synchronous.dart';
import 'package:test/test.dart';

void main() {
  test('synchronous ...', () async {
    final p = ProcessSync()..run(ProcessSettings('cat'));

    for (var i = 0; i < 10; i++) {
      p.write('line $i\n');
      final line = p.readStdout();
      print('from cat: $line');
    }
  });
}
