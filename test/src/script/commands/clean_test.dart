@Timeout(Duration(seconds: 600))

import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

String script = 'test/test_scripts/general/bin/hello_world.dart';

void main() {
  group('Preparing using DCli', () {
    test('warmup ', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = join('example', 'dsort.dart');
        var script = Script.fromFile(scriptPath);
        var exePath = join(script.pathToScriptDirectory, script.exeName);

        if (exists(exePath)) delete(exePath);
        DartProject.fromPath('example').warmup();
        expect(exists(exePath), equals(true));
      });
    });

    test('warmup  with a local pubspec', () {
      TestFileSystem().withinZone((fs) {
        var scriptPath = 'test/test_scripts/local_pubspec/hello_world.dart';
        var script = Script.fromFile(scriptPath);
        var exePath = join(script.pathToScriptDirectory, script.exeName);

        if (exists(exePath)) delete(exePath);
        DartProject.fromPath('example').warmup();
        expect(exists(exePath), equals(true));
      });
    });
  });
}
