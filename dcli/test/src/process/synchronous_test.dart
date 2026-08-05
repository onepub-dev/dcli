import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
void main() {
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
