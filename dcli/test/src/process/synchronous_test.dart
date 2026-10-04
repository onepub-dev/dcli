import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
void main() {
  test('silent child survives multiple mailbox polling intervals', () {
    final temporary = Directory.systemTemp.createTempSync('dcli silent child ');
    try {
      final script = File('${temporary.path}/child.dart')
        ..writeAsStringSync('''
import 'dart:io';
void main() {
  sleep(const Duration(seconds: 5));
  print('finished');
  stderr.writeln('child stderr');
  exit(23);
}
''');
      final progress = Progress.capture();
      final result = startFromArgs(
        Platform.resolvedExecutable,
        [script.path],
        nothrow: true,
        progress: progress,
      );
      expect(result.exitCode, 23);
      expect(progress.toList(), containsAll(['finished', 'child stderr']));
    } finally {
      temporary.deleteSync(recursive: true);
    }
  });

  // test('synchronous ...', () async {
  //   final p = ProcessSync()..run(ProcessSettings('cat'));

  //   for (var i = 0; i < 10; i++) {
  //     p.writeLine('line $i\n');
  //     final line = p.readStdout();
  //     print('from cat: $line');
  //   }
  // });

  test('startFromArgs exposes the exit code', () {
    final progress = Progress.capture();
    final result = startFromArgs(
      Platform.executable,
      ['--version'],
      nothrow: true,
      progress: progress,
    );

    expect(result.exitCode, equals(0));
  });
}
