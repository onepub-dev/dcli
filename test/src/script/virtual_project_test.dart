@Timeout(Duration(minutes: 10))
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  group('Virtual Project ', () {
    test('Doctor - local pubspec', () {
      TestFileSystem().withinZone((fs) {
        final scriptDir = join(fs.unitTestWorkingDir, 'local');

        createDir(scriptDir, recursive: true);

        final scriptPath = join(scriptDir, 'local.dart');

        'dcli create $scriptPath'.run;

        final script = Script.fromFile(scriptPath);

        script.doctor;
      });
    });

    test('Doctor - virtual pubspec', () {
      TestFileSystem().withinZone((fs) {
        final scriptDir = join(fs.unitTestWorkingDir, 'virtual');

        createDir(scriptDir, recursive: true);

        final scriptPath = join(scriptDir, 'virtual.dart');

        'dcli create $scriptPath'.run;

        final script = Script.fromFile(scriptPath);

        script.doctor;
      });
    });

    test('Doctor - traditional pubspec', () {
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

        final script = Script.fromFile(scriptPath);

        script.doctor;
      });
    });

    test('Doctor - annotation pubspec', () {
      TestFileSystem().withinZone((fs) {
        final scriptDir = join(fs.unitTestWorkingDir, 'annotation');

        createDir(scriptDir, recursive: true);
        const scriptName = 'annotation.dart';
        final scriptPath = join(scriptDir, scriptName);

        const scriptContent = '''
#! /bin/env dcli

/**
 * @pubspec
 * name: annotation_test
 * dependencies:
 *   dcli: ^0.20.0
 *   skippy: ^2.0.0
 */
void main(){
}
''';
        scriptPath.write(scriptContent);

        final script = Script.fromFile(scriptPath);

        script.doctor;
      });
    });
  });
}
