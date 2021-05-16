@Timeout(Duration(minutes: 5))
import 'package:dcli/src/util/dcli_paths.dart';
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  t.group('String as Process', () {
    TestFileSystem().withinZone((fs) {
      t.test('Basic .run', () {
        final testFile = join(fs.fsRoot, 'test.text');

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch $testFile'.run;
        t.expect(exists(testFile), t.equals(true));
      });

      t.test('print stdout', () {
        final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));
        final script = truepath(scriptPath, 'print_to_stdout.dart');

        final results = runChild(script, fs);

        final expected = <String>['Hello World'];

        t.expect(results, t.equals(expected));
      });

      t.test('print stderr', () {
        final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));
        final script = truepath(scriptPath, 'print_to_stderr.dart');

        final results = runChild(script, fs);

        final expected = <String>['Hello World - Error'];

        t.expect(results, t.equals(expected));
      });

      t.test('print stdout and stderr', () {
        final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));

        if (!exists(scriptPath)) {
          createDir(scriptPath, recursive: true);
        }
        final script = truepath(scriptPath, 'print_to_both.dart');
        final results = runChild(script, fs);

        final expected = <String>[
          'Hello World - StdOut',
          'Hello World - StdErr'
        ];

        t.expect(results, t.equals(expected));
      });

      t.test('print stdout and stderr with error', () {
        final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));

        if (!exists(scriptPath)) {
          createDir(scriptPath, recursive: true);
        }
        final script = truepath(scriptPath, 'print_to_both_with_error.dart');

        final results = runChild(script, fs);

        final expected = <String>[
          'Hello World - StdOut',
          'Hello World - StdErr'
        ];

        t.expect(results, t.containsAll(expected));
      });
    });
  });
}

List<String?> runChild(String childScript, TestFileSystem fs) {
  /// The run_child.script file will use .run to run [script].
  final runChildScript =
      truepath(join(fs.testScriptPath, 'general/bin', 'run_child.dart'));

  // make certain our test script will run
  '${DCliPaths().dcliName} -v warmup ${dirname(childScript)}'.run;
  '${DCliPaths().dcliName} -v warmup ${dirname(runChildScript)}'.run;

  // run a script that uses '.run' and capture its output to prove
  // that .run works.
  final results = '${DCliPaths().dcliName} $runChildScript $childScript'
      .toList(nothrow: true);

  return results;
}
