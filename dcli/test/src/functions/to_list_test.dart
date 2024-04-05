@Timeout(Duration(minutes: 5))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart';
import 'package:test/test.dart' as t;
import 'package:test/test.dart';

void main() {
  t.group('toList', () {
    t.test('Check .toList captures stdout', () async {
      await TestFileSystem().withinZone((fs) async {
        final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));

        final script = truepath(scriptPath, 'print_to_stdout.dart');

        // make certain our test script will run
        '${DCliPaths().dcliName} -v warmup  ${dirname(script)}'.run;

        print('calling toList');

        // run a script that prints to stdout and prove that toList captures it.
        final results = '${DartSdk().pathToDartExe} $script'.toList();

        final expected = <String>['Hello World'];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('Check .toList captures stderr', () async {
      await TestFileSystem().withinZone((fs) async {
        final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));

        final script = truepath(scriptPath, 'print_to_stderr.dart');

        // make certain our test script will run
        '${DCliPaths().dcliName} -v warmup  ${dirname(script)}'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        final results =
            '${DartSdk().pathToDartExe} $script'.toList(nothrow: true);

        final expected = <String>['Hello World - Error'];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('Check .toList captures stderr and stdout', () async {
      await TestFileSystem().withinZone((fs) async {
        final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));

        final script = truepath(scriptPath, 'print_to_both.dart');

        // make certain our test script will run
        '${DCliPaths().dcliName} -v warmup  ${dirname(script)}'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        final results =
            '${DartSdk().pathToDartExe} $script'.toList(nothrow: true);

        final expected = <String>[
          'Hello World - StdOut',
          'Hello World - StdErr'
        ];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('Check .toList captures stderr and stdout when non-zero exit occurs',
        () async {
      await TestFileSystem().withinZone((fs) async {
        final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));

        final script = truepath(scriptPath, 'print_to_both_with_error.dart');

        // make certain our test script will run
        '${DCliPaths().dcliName} -v warmup  ${dirname(script)}'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        final results =
            '${DartSdk().pathToDartExe} $script'.toList(nothrow: true);

        final expected = <String>[
          'Hello World - StdOut',
          'Hello World - StdErr'
        ];

        t.expect(results, t.equals(expected));
      });
    });
  });
}
