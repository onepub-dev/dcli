import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  for (final sudoReadsPassword in [false, true]) {
    test('remote commands cannot read the password stream '
        '(sudo reads password: $sudoReadsPassword)', () async {
      if (Platform.isWindows) {
        return;
      }
      final command = Remote.buildPasswordedCommand('cat; printf safe');
      expect(command, isNot(contains('private password')));
      final sudo = sudoReadsPassword
          ? 'sudo() { IFS= read -r ignored; shift; shift; "\$@"; }; '
          : 'sudo() { sleep 0.2; shift; shift; "\$@"; }; ';
      final process = await Process.start('sh', ['-c', '$sudo$command']);
      process.stdin.writeln('private password with \$(printf BAD)');
      await process.stdin.close();
      final output = await process.stdout.transform(utf8.decoder).join();
      final error = await process.stderr.transform(utf8.decoder).join();
      expect(await process.exitCode, 0, reason: error);
      expect(output, 'safe');
    });
  }

  test('leading-dash SSH host is treated as a host, not an option', () {
    if (Platform.isWindows) {
      return;
    }
    expect(
      () => Remote().exec(host: '-V', command: 'true'),
      throwsA(isA<RunException>()),
    );
  });

  test('leading-dash SCP source is copied as a file, not parsed as an option',
      () {
    if (Platform.isWindows) {
      return;
    }
    final temp = Directory.systemTemp.createTempSync('dcli-scp-');
    final previous = Directory.current;
    try {
      Directory.current = temp.path;
      File('-V').writeAsStringSync('source');
      Remote().scp(from: ['-V'], to: 'copied');
      expect(File('copied').readAsStringSync(), 'source');
    } finally {
      Directory.current = previous;
      temp.deleteSync(recursive: true);
    }
  });

  test('remote sudo password stays out of process errors', () {
    if (Platform.isWindows) {
      return;
    }

    const password = 'private password with spaces and shell punctuation';
    expect(
      () => Remote().exec(
        host: '-invalid-host',
        command: 'true',
        sudo: true,
        password: password,
      ),
      throwsA(
        isA<RunException>().having(
          (error) => error.toString(),
          'error',
          isNot(contains(password)),
        ),
      ),
    );
  });
}
