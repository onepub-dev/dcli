@Timeout(Duration(minutes: 5))
library;

import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart' show truepath;
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  for (final mode in ['startFromArgs', 'start']) {
    test('includeParentEnvironment false prevents env leak ($mode)', () async {
      await TestFileSystem().withinZone((fs) async {
        final scriptPath = truepath(
          join(fs.testScriptPath, 'general', 'bin', 'include_parent_env.dart'),
        );

        final process = await Process.start(
          Platform.resolvedExecutable,
          [scriptPath, mode],
          environment: {'MY_VAR': 'secret'},
        );

        final output = await process.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .toList();
        final errorOutput = await process.stderr
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .toList();

        final exitCode = await process.exitCode;
        expect(
          exitCode,
          equals(0),
          reason: 'stdout: $output\nstderr: $errorOutput',
        );
        expect(output, equals(['Child sees MY_VAR: (not set)']));
      });
    });
  }
}
