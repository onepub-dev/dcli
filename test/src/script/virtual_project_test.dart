@Timeout(Duration(minutes: 10))
import 'package:dshell/dshell.dart';
import 'package:dshell/src/script/virtual_project.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import '../util/test_file_system.dart';

void main() {
  group('Virtual Project ', () {
    test('Doctor - local pubspec', () {
      TestFileSystem().withinZone((fs) {
        var scriptDir = join(fs.unitTestWorkingDir, 'local');

        createDir(scriptDir, recursive: true);

        var scriptPath = join(scriptDir, 'local.dart');

        'dshell create $scriptPath'.run;

        /// create a local pubspec for the script.
        'dshell split $scriptPath'.run;

        var script = Script.fromFile(scriptPath);

        var project = VirtualProject.load(script);

        project.doctor;
      });
    });

    test('Doctor - virtual pubspec', () {
      TestFileSystem().withinZone((fs) {
        var scriptDir = join(fs.unitTestWorkingDir, 'virtual');

        createDir(scriptDir, recursive: true);

        var scriptPath = join(scriptDir, 'virtual.dart');

        'dshell create $scriptPath'.run;

        var script = Script.fromFile(scriptPath);

        var project = VirtualProject.load(script);

        project.doctor;
      });
    });

    test('Doctor - traditional pubspec', () {
      TestFileSystem().withinZone((fs) {
        var scriptDir = join(fs.unitTestWorkingDir, 'traditional');

        createDir(scriptDir, recursive: true);
        var scriptName = 'traditional.dart';
        var scriptPath = join(scriptDir, scriptName);

        'dshell create $scriptPath'.run;

        /// create a local pubspec for the script.
        'dshell split $scriptPath'.run;

        /// move the script into a bin directory to mimic a traditional dart package layout.
        var binDir = join(scriptDir, 'bin');
        createDir(binDir);
        move(scriptPath, binDir);
        scriptPath = join(binDir, scriptName);

        var script = Script.fromFile(scriptPath);

        var project = VirtualProject.load(script);

        project.doctor;
      });
    });

    test('Doctor - annotation pubspec', () {
      TestFileSystem().withinZone((fs) {
        var scriptDir = join(fs.unitTestWorkingDir, 'annotation');

        createDir(scriptDir, recursive: true);
        var scriptName = 'annotation.dart';
        var scriptPath = join(scriptDir, scriptName);

        var scriptContent = '''#! /bin/env dshell

/**
 * @pubspec
 * name: annotation_test
 * dependencies:
 *   dshell: ^1.0.0
 *   skippy: ^2.0.0
 */
void main(){
}
''';
        scriptPath.write(scriptContent);

        var script = Script.fromFile(scriptPath);

        var project = VirtualProject.create(script);

        project.doctor;
      });
    });
  });
}
