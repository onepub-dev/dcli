import 'package:dshell/src/script/entry_point.dart';
@Timeout(Duration(seconds: 600))
import 'package:test/test.dart' as t;
import 'package:dshell/dshell.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  TestFileSystem();

  Settings().debug_on = true;
  t.group('RunCommand', () {
    t.test('Does command run', () {
      TestFileSystem().withinZone((fs) {
        var testFile = 'test.text';

        if (exists(testFile)) {
          delete(testFile);
        }

        'touch test.text'.run;
        t.expect(exists(testFile), t.equals(true));
      });
    });

    t.test('Does command write output to stdout', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = truepath(TestFileSystem().testScriptPath, 'run_test');

        if (!exists(scriptPath)) {
          createDir(scriptPath, recursive: true);
        }
        var script = truepath(scriptPath, 'run_echo.dart');

        // make certain our test script will run
        'dshell -v create -fg $script'.run;

        // run a script that uses '.run' and capture its output to prove
        // that .run works.
        var results = 'dshell $script'.toList();

        var expected = <String>['Hello World'];

        t.expect(results, t.equals(expected));

        deleteDir(scriptPath, recursive: true);
      });
    });

    // This entry point exists to make easy to debug the run
    // command.
    t.test('Debug test point', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = truepath(TestFileSystem().testScriptPath, 'run_test');

        if (!exists(scriptPath)) {
          createDir(scriptPath, recursive: true);
        }
        var script = truepath(scriptPath, 'run_echo.dart');

        // make certain our test script exists and is in a runnable state.
        'dshell -v create -fg $script'.run;

        EntryPoint().process(['run', script]);

        deleteDir(scriptPath, recursive: true);
      });
    });

    //  t.test('Does run expand wildcards', () {
    //   TestFileSystem().withinZone((fs){
    //     var testFile = 'test.text';
    //     var testFile1 = 'test2.text';

    //     touch(testFile);
    //     touch(testFile1);

    //     'echo *.text'.run;
    //     t.expect(exists(testFile), t.equals(true));

    //       if (exists(testFile)) {
    //       delete(testFile);

    //   });
    // });
  });
}
