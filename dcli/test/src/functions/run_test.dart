@Timeout(Duration(minutes: 5))
library;

import 'package:dcli/dcli.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart';
import 'package:test/test.dart' as t;
import 'package:test/test.dart';

void main() {
  t.group('String as Process', () {
    t.test('Basic .run', () async {
      await TestFileSystem().withinZone((fs) async {
        await withTestScope((tmpDir) async {
          final testFile = join(fs.fsRoot, 'test.text');

          if (exists(testFile)) {
            delete(testFile);
          }

          'touch $testFile'.run;
          t.expect(exists(testFile), t.equals(true));
        });
      });
    });

    t.test('no output', ()  {
      // pid should not exist.
      ' ps -q 218139512 -o comm='.start(nothrow: true);
    });

    t.test('print stdout', () async {
      await TestFileSystem().withinZone((fs) async {
        await withTestScope((tmpDir) async {
          final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));
          final script = truepath(scriptPath, 'print_to_stdout.dart');

          final results = runChild(script);

          final expected = <String>['Hello World'];

          t.expect(results, t.equals(expected));
        });
      });
    });

    t.test('print stderr', () async {
      await TestFileSystem().withinZone((fs) async {
        await withTestScope((tmpDir) async {
          final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));
          final script = truepath(scriptPath, 'print_to_stderr.dart');

          final results = runChild(script);

          final expected = <String>['Hello World - Error'];

          t.expect(results, t.equals(expected));
        });
      });
    });
    t.test('print stdout and stderr', () async {
      await TestFileSystem().withinZone((fs) async {
        await withTestScope((tmpDir) async {
          final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));

          if (!exists(scriptPath)) {
            createDir(scriptPath, recursive: true);
          }
          final script = truepath(scriptPath, 'print_to_both.dart');
          final results = runChild(script);

          final expected = <String>[
            'Hello World - StdOut',
            'Hello World - StdErr'
          ];

          t.expect(results, t.equals(expected));
        });
      });
    });

    t.test('print stdout and stderr with error', () async {
      await TestFileSystem().withinZone((fs) async {
        await withTestScope((tmpDir) async {
          final scriptPath = truepath(join(fs.testScriptPath, 'general/bin'));

          if (!exists(scriptPath)) {
            createDir(scriptPath, recursive: true);
          }
          final script = truepath(scriptPath, 'print_to_both_with_error.dart');

          final results = runChild(script);

          final expected = <String>[
            'Hello World - StdOut',
            'Hello World - StdErr'
          ];

          t.expect(results, t.containsAll(expected));
        });
      });
    });

    t.test('Missing exectuable', () async {
      await withTestScope((tmpDir) async {
        final pathToBadScript = join(
            rootPath, 'bad', 'path', 'to', 'non', 'existant', 'script.dart');
        t.expect(() {
          pathToBadScript.toList(nothrow: true);
        },
            throwsA(predicate((e) =>
                e is RunException &&
                e.exitCode == 2 &&
                e.reason == 'Could not find $pathToBadScript on the path.')));
      });
    });
  });
}

List<String?> runChild(String pathToChildScript) {
  /// The run_child script will be used .start(nothrow) the [pathToChildScript].

  final childScript = DartScript.fromFile(pathToChildScript);
  if (!childScript.isReadyToRun) {
    childScript.runPubGet();
  }

  // make certain our test script will run
  '${DCliPaths().dcliName} -v warmup ${dirname(pathToChildScript)}'.run;
  // run a script that uses '.run' and capture its output to prove
  // that .run works.
  final results =
      '''${join(TestFileSystem.pathToTools, 'run_child')} "$pathToChildScript"'''
          .toList(nothrow: true);

  return results;
}
