@Timeout(Duration(minutes: 10))
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  group('Create Script ', () {
    test('Doctor - local pubspec', () {
      TestFileSystem().withinZone((fs) {
        final scriptDir = join(fs.unitTestWorkingDir, 'local');

        createDir(scriptDir, recursive: true);

        final scriptPath = join(scriptDir, 'local.dart');

        'dcli create $scriptPath'.run;

        DartScript.fromFile(scriptPath).doctor;
      });
    });
    test('Create script', () {
      TestFileSystem().withinZone((fs) {
        final scriptDir = join(fs.unitTestWorkingDir, 'traditional');

        createDir(scriptDir, recursive: true);
        const scriptName = 'traditional.dart';
        var scriptPath = join(scriptDir, scriptName);

        'dcli create $scriptPath'.run;

        /// move the script into a bin directory to mimic a
        /// traditional dart package layout.
        final binDir = join(scriptDir, 'bin');
        createDir(binDir);
        move(scriptPath, binDir);
        scriptPath = join(binDir, scriptName);

        DartScript.fromFile(scriptPath).doctor;
      });
    });
  });
}
