@Timeout(Duration(seconds: 600))
import 'package:dshell/dshell.dart' hide equals;
import 'package:dshell/src/pubspec/global_dependencies.dart';
import 'package:dshell/src/pubspec/pubspec_manager.dart';
import 'package:dshell/src/script/dependency.dart';
import 'package:dshell/src/script/script.dart';
import 'package:dshell/src/script/virtual_project.dart';
import 'package:test/test.dart';

import '../util/test_paths.dart';

void main() {
  TestPaths();

  test('load', () {
    var content = '''
dependencies:
  args: ^1.5.2
  collection: ^1.14.12
  file_utils: ^0.1.3
  path: ^1.6.4
  ''';

    var expected = [
      Dependency.fromHosted('args', '^1.5.2'),
      Dependency.fromHosted('collection', '^1.14.12'),
      Dependency.fromHosted('file_utils', '^0.1.3'),
      Dependency.fromHosted('path', '^1.6.4'),
    ];

    var gd = GlobalDependencies.fromString(content);
    expect(gd.dependencies, equals(expected));
  });

  test('dependency_overrides', () {
    var content = '''
dependencies:
  args: ^1.5.2
  collection: ^1.14.12
  file_utils: ^0.1.3
  path: ^1.6.4
  dshell:
    path: /home/dshell
dependency_overrides:
  args:
    path: /home/args
  ''';

    var expected = [
      Dependency.fromPath('args', '/home/args'),
      Dependency.fromHosted('collection', '^1.14.12'),
      Dependency.fromHosted('file_utils', '^0.1.3'),
      Dependency.fromHosted('path', '^1.6.4'),
      Dependency.fromPath('dshell', '/home/dshell'),
    ];

    var gd = GlobalDependencies.fromString(content);
    expect(gd.dependencies, equals(expected));
  });

  test('local dshell', () {
    var content = '''
dependencies:
  dshell: ^1.0.44 
  args: ^1.5.2
  path: ^1.6.4

dependency_overrides:
  dshell: 
    path: /home/dshell
  ''';

    var expected = [
      Dependency.fromPath('dshell', '/home/dshell'),
      Dependency.fromHosted('args', '^1.5.2'),
      Dependency.fromHosted('path', '^1.6.4'),
    ];

    var gd = GlobalDependencies.fromString(content);
    expect(gd.dependencies, equals(expected));
  });

  test('local dshell - with file writes', () {
    var content = '''
dependencies:
  dshell: ^1.0.44 
  args: ^1.5.2
  path: ^1.6.4

dependency_overrides:
  dshell: 
    path: /home/dshell
  ''';

    var paths = TestPaths();

    var workingDir = paths.unitTestWorkingDir;

    // create a temp 'dependencies.yaml
    var depPath = join(workingDir, 'dependencies.yaml');

    depPath.write(content);

    var gd = GlobalDependencies.fromFile(depPath);

    var expected = [
      Dependency.fromPath('dshell', '/home/dshell'),
      Dependency.fromHosted('args', '^1.5.2'),
      Dependency.fromHosted('path', '^1.6.4'),
    ];

    expect(gd.dependencies, equals(expected));
  });

  test('local dshell - write virtual pubsec.yaml', () {
    var content = '''
dependencies:
  dshell: ^1.0.44 
  args: ^1.5.2
  path: ^1.6.4

dependency_overrides:
  dshell: 
    path: ~/git/dshell
  ''';

    var paths = TestPaths();

    var workingDir = paths.unitTestWorkingDir;

    // create a temp 'dependencies.yaml
    var depPath = join(workingDir, 'dependencies.yaml');

    depPath.write(content);

    var gd = GlobalDependencies.fromFile(depPath);

    var expected = [
      Dependency.fromPath('dshell', '~/git/dshell'),
      Dependency.fromHosted('args', '^1.5.2'),
      Dependency.fromHosted('path', '^1.6.4'),
    ];

    expect(gd.dependencies, equals(expected));

    var testScriptPath = join(workingDir, 'depends_test.dart');

    // create a script
    testScriptPath.write('''
    void main()
    {
      print('hellow world');
    }
    ''');

    // load it
    var script = Script.fromFile(testScriptPath);

    // create a virtual project for it.
    var project = VirtualProject(TestPaths.TEST_ROOT, script);
    project.createProject(skipPubGet: true);

    var manager = PubSpecManager(project);
    manager.createVirtualPubSpec();

    var pubspec = project.pubSpec();

    expect(
        pubspec.dependencies..sort((lhs, rhs) => lhs.name.compareTo(rhs.name)),
        equals(
            gd.dependencies..sort((lhs, rhs) => lhs.name.compareTo(rhs.name))));
  });
}
