@Timeout(Duration(minutes: 5))
import 'package:dcli/src/util/dcli_paths.dart';
import 'package:test/test.dart' as t;
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  t.group('.run', () {
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

    t.test('print stdout', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = truepath(join('test', 'test_scripts'));
        var script = truepath(scriptPath, 'print_to_stdout.dart');

        var results = run_child(script);

        var expected = <String>['Hello World'];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('print stderr', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = truepath(join('test', 'test_scripts'));
        var script = truepath(scriptPath, 'print_to_stderr.dart');

        var results = run_child(script);

        var expected = <String>['Hello World - Error'];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('print stdout and stderr', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = truepath(join('test', 'test_scripts'));

        if (!exists(scriptPath)) {
          createDir(scriptPath, recursive: true);
        }
        var script = truepath(scriptPath, 'print_to_both.dart');
        var results = run_child(script);

        var expected = <String>['Hello World', 'Hello World - Error'];

        t.expect(results, t.equals(expected));
      });
    });

    t.test('print stdout and stderr with error', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = truepath(join('test', 'test_scripts'));

        if (!exists(scriptPath)) {
          createDir(scriptPath, recursive: true);
        }
        var script = truepath(scriptPath, 'print_to_both_with_error.dart');

        var results = run_child(script);

        var expected = <String>['Hello World', 'Hello World - Error'];

        t.expect(results, t.containsAll(expected));
      });
    });
  });
}

List<String> run_child(String childScript) {
  /// The run_child.script file will use .run to run [script].
  var runChildScript = truepath(join('test', 'test_scripts', 'run_child.dart'));

  // make certain our test script will run
  '${DCliPaths().dcliName} -v clean $childScript'.run;
  '${DCliPaths().dcliName} -v clean $runChildScript'.run;

  // run a script that uses '.run' and capture its output to prove
  // that .run works.
  var results = '${DCliPaths().dcliName} $runChildScript $childScript'
      .toList(nothrow: true);

  return results;
}
