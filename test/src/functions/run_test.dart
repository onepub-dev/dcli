@Timeout(Duration(minutes: 5))
import 'package:dshell/src/util/dshell_paths.dart';
import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  t.group('RunCommand', () {
    t.test('Basic .run', () {
      TestFileSystem().withinZone((fs) {
        var testFile = join(fs.root, 'test.text');

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch $testFile'.run;
        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test('Check .run captures stdout', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = truepath(join('test', 'test_scripts'));
        var script = truepath(scriptPath, 'print_to_stdout.dart');

        // make certain our test script will run
        '${DShellPaths().dshellName} -v clean $script'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        var results = '${DShellPaths().dshellName} $script'.toList();

        var expected = <String>['Hello World'];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('Check .run captures stderr', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = truepath(join('test', 'test_scripts'));
        var script = truepath(scriptPath, 'print_to_stderr.dart');

        // make certain our test script will run
        '${DShellPaths().dshellName} -v clean  $script'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        var results = '${DShellPaths().dshellName} $script'.toList();

        var expected = <String>['Hello World - Error'];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('Does .run capture stdout and stderr', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = truepath(join('test', 'test_scripts'));

        if (!exists(scriptPath)) {
          createDir(scriptPath, recursive: true);
        }
        var script = truepath(scriptPath, 'print_to_both.dart');

        // make certain our test script will run
        '${DShellPaths().dshellName} -v clean $script'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        var results = '${DShellPaths().dshellName} $script'.toList();

        var expected = <String>['Hello World', 'Hello World - Error'];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('Run method should display both stdout and stderr with error', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = truepath(join('test', 'test_scripts'));

        if (!exists(scriptPath)) {
          createDir(scriptPath, recursive: true);
        }
        var script = truepath(scriptPath, 'print_to_both_with_error.dart');

        // make certain our test script will run
        '${DShellPaths().dshellName} -v clean $script'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        var results = '${DShellPaths().dshellName} $script'.toList();

        var expected = <String>['Hello World', 'Hello World - Error'];

        t.expect(results, t.equals(expected));
      });
    });
  });
}
