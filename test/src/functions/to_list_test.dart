@Timeout(Duration(minutes: 5))

import 'package:dcli/dcli.dart';
import 'package:dcli/src/util/dcli_paths.dart';
import 'package:test/test.dart' as t;
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  t.group('toList', () {
    t.test('Check .toList captures stdout', () {
      TestFileSystem().withinZone((fs) {
        final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));

        final script = truepath(scriptPath, 'print_to_stdout.dart');

        // make certain our test script will run
        '${DCliPaths().dcliName} -v warmup  ${dirname(script)}'.run;

        // run a script that prints to stdout and prove that toList captures it.
        final results = '${DCliPaths().dcliName} $script'.toList();

        final expected = <String>['Hello World'];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('Check .toList captures stderr', () {
      TestFileSystem().withinZone((fs) {
        final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));

        final script = truepath(scriptPath, 'print_to_stderr.dart');

        // make certain our test script will run
        '${DCliPaths().dcliName} -v warmup  ${dirname(script)}'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        final results = '${DCliPaths().dcliName} $script'.toList(nothrow: true);

        final expected = <String>['Hello World - Error'];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('Check .toList captures stderr and stdout', () {
      TestFileSystem().withinZone((fs) {
        final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));

        final script = truepath(scriptPath, 'print_to_both.dart');

        // make certain our test script will run
        '${DCliPaths().dcliName} -v warmup  ${dirname(script)}'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        final results = '${DCliPaths().dcliName} $script'.toList(nothrow: true);

        final expected = <String>[
          'Hello World - StdOut',
          'Hello World - StdErr'
        ];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('Check .toList captures stderr and stdout when non-xero exit occurs',
        () {
      TestFileSystem().withinZone((fs) {
        final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));

        final script = truepath(scriptPath, 'print_to_both_with_error.dart');

        // make certain our test script will run
        '${DCliPaths().dcliName} -v warmup  ${dirname(script)}'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        final results = '${DCliPaths().dcliName} $script'.toList(nothrow: true);

        final expected = <String>[
          'Hello World - StdOut',
          'Hello World - StdErr'
        ];

        t.expect(results, t.equals(expected));
      });
    });
  });
}
