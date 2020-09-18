@Timeout(Duration(minutes: 5))
import 'package:dcli/src/util/dcli_paths.dart';
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  t.group('toList', () {
    t.test('Check .toList captures stdout', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = truepath(join('test', 'test_scripts/general/bin'));

        var script = truepath(scriptPath, 'print_to_stdout.dart');

        // make certain our test script will run
        '${DCliPaths().dcliName} -v warmup  ${dirname(script)}'.run;

        // run a script that prints to stdout and prove that toList captures it.
        var results = '${DCliPaths().dcliName} $script'.toList();

        var expected = <String>['Hello World'];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('Check .toList captures stderr', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = truepath(join('test', 'test_scripts/general/bin'));

        var script = truepath(scriptPath, 'print_to_stderr.dart');

        // make certain our test script will run
        '${DCliPaths().dcliName} -v warmup  ${dirname(script)}'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        var results = '${DCliPaths().dcliName} $script'.toList(nothrow: true);

        var expected = <String>['Hello World - Error'];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('Check .toList captures stderr and stdout', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = truepath(join('test', 'test_scripts/general/bin'));

        var script = truepath(scriptPath, 'print_to_both.dart');

        // make certain our test script will run
        '${DCliPaths().dcliName} -v warmup  ${dirname(script)}'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        var results = '${DCliPaths().dcliName} $script'.toList(nothrow: true);

        var expected = <String>['Hello World', 'Hello World - Error'];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('Check .toList captures stderr and stdout when non-xero exit occurs',
        () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = truepath(join('test', 'test_scripts/general/bin'));

        var script = truepath(scriptPath, 'print_to_both_with_error.dart');

        // make certain our test script will run
        '${DCliPaths().dcliName} -v warmup  ${dirname(script)}'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        var results = '${DCliPaths().dcliName} $script'.toList(nothrow: true);

        var expected = <String>['Hello World', 'Hello World - Error'];

        t.expect(results, t.equals(expected));
      });
    });
  });
}
