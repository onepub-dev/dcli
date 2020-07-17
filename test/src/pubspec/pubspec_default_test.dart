@t.Timeout(Duration(seconds: 600))
import 'package:dshell/dshell.dart';
import 'package:dshell/src/pubspec/global_dependencies.dart';
import 'package:dshell/src/pubspec/pubspec.dart';
import 'package:dshell/src/script/dependency.dart';
import 'package:dshell/src/script/project_cache.dart';
import 'package:dshell/src/script/script.dart';
import 'package:dshell/src/script/virtual_project.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart' as t;

import '../util/test_file_system.dart';

void main() {
  var main = '''
void main()
{
  print ('hello world');
}
''';

  var basic = '''name: test
version: 1.0.0
dependencies:
  collection: ^1.14.12
  file_utils: ^0.1.3
''';

  var overrides = '''name: test
version: 1.0.0
dependencies:
  dshell: ^2.0.0
  args: ^2.0.1
  collection: ^1.14.12
  file_utils: ^0.1.3
  path: ^2.0.2
''';

  t.test('No PubSpec - No Dependencies', () {
    TestFileSystem().withinZone((fs) {
      var scriptDirectory = p.join(fs.root, 'local');
      var pubSpecScriptPath = p.join(scriptDirectory, 'pubspec.yaml');

      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      runTest(fs, null, main, GlobalDependencies.defaultDependencies);
    });
  }, skip: false);

  var annotationNoOverrides = '''
    /* @pubspec
$basic
*/
  ''';

  t.test('Annotation - No Overrides', () {
    TestFileSystem().withinZone((fs) {
      var scriptDirectory = p.join(fs.root, 'local');
      var pubSpecScriptPath = p.join(scriptDirectory, 'pubspec.yaml');

      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      var dependencies = GlobalDependencies.defaultDependencies;
      dependencies.add(Dependency.fromHosted('collection', '^1.14.12'));
      dependencies.add(Dependency.fromHosted('file_utils', '^0.1.3'));
      runTest(fs, annotationNoOverrides, main, dependencies);
    });
  }, skip: false);

  var annotationWithOverrides = '''
    /* @pubspec
$overrides
*/
  ''';

  t.test('Annotaion With Overrides', () {
    TestFileSystem().withinZone((fs) {
      var scriptDirectory = p.join(fs.root, 'local');
      var pubSpecScriptPath = p.join(scriptDirectory, 'pubspec.yaml');

      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      var dependencies = <Dependency>[];
      dependencies.add(Dependency.fromHosted('dshell', '^2.0.0'));
      dependencies.add(Dependency.fromHosted('args', '^2.0.1'));
      dependencies.add(Dependency.fromHosted('path', '^2.0.2'));
      dependencies.add(Dependency.fromHosted('collection', '^1.14.12'));
      dependencies.add(Dependency.fromHosted('file_utils', '^0.1.3'));
      runTest(fs, annotationWithOverrides, main, dependencies);
    });
  }, skip: false);

  t.test('File - basic', () {
    TestFileSystem().withinZone((fs) {
      var scriptDirectory = p.join(fs.root, 'local');
      var scriptPath = p.join(scriptDirectory, 'test.dart');
      var pubSpecScriptPath = p.join(scriptDirectory, 'pubspec.yaml');
      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      if (!exists(dirname(scriptPath))) {
        createDir(dirname(scriptPath));
      }
      PubSpec file = PubSpecImpl.fromString(basic);
      file.saveToFile(pubSpecScriptPath);

      var dependencies = <Dependency>[];
      dependencies.add(Dependency.fromHosted('collection', '^1.14.12'));
      dependencies.add(Dependency.fromHosted('file_utils', '^0.1.3'));
      runTest(fs, null, main, dependencies);
    });
  }, skip: false);

  t.test('File - override', () {
    TestFileSystem().withinZone((fs) {
      var scriptDirectory = p.join(fs.root, 'local');
      var scriptPath = p.join(scriptDirectory, 'test.dart');
      var pubSpecScriptPath = p.join(scriptDirectory, 'pubspec.yaml');
      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      PubSpec file = PubSpecImpl.fromString(overrides);
      file.saveToFile(scriptPath);

      var dependencies = <Dependency>[];
      dependencies.add(Dependency.fromHosted('dshell', '^2.0.0'));
      dependencies.add(Dependency.fromHosted('args', '^2.0.1'));
      dependencies.add(Dependency.fromHosted('path', '^2.0.2'));
      dependencies.add(Dependency.fromHosted('collection', '^1.14.12'));
      dependencies.add(Dependency.fromHosted('file_utils', '^0.1.3'));
      runTest(fs, null, main, dependencies);
    });
  }, skip: false);

  t.test('File - local pubsec.yaml', () {
    TestFileSystem().withinZone((fs) {
      var scriptDirectory = p.join(fs.root, 'local');
      var scriptPath = p.join(scriptDirectory, 'test.dart');
      var pubSpecScriptPath = p.join(scriptDirectory, 'pubspec.yaml');
      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      PubSpec file = PubSpecImpl.fromString(overrides);
      file.saveToFile(scriptPath);

      var dependencies = <Dependency>[];
      dependencies.add(Dependency.fromHosted('dshell', '^2.0.0'));
      dependencies.add(Dependency.fromHosted('args', '^2.0.1'));
      dependencies.add(Dependency.fromHosted('path', '^2.0.2'));
      dependencies.add(Dependency.fromHosted('collection', '^1.14.12'));
      dependencies.add(Dependency.fromHosted('file_utils', '^0.1.3'));
      runTest(fs, null, main, dependencies);
    });
  }, skip: false);
}

void runTest(TestFileSystem fs, String annotation, String main,
    List<Dependency> expected) {
  var scriptDirectory = p.join(fs.root, 'local');
  var scriptPath = p.join(scriptDirectory, 'test.dart');
  var script = Script.fromFile(scriptPath);

  // reset everything
  if (exists(scriptPath)) {
    delete(scriptPath);
  }

  if (exists(Settings().dshellPath)) {
    deleteDir(Settings().dshellPath, recursive: true);
  }

  if (!exists(Settings().dshellPath)) {
    createDir(Settings().dshellPath);
  }
  GlobalDependencies.createDefault();

  ProjectCache().initCache();

  if (!exists(scriptDirectory)) {
    createDir(scriptDirectory, recursive: true);
  }
  if (annotation != null) {
    scriptPath.append(annotation);
  }
  scriptPath.append(main);

  var project = VirtualProject.create(script);

  var pubspec = project.pubSpec();
  t.expect(pubspec.dependencies, t.unorderedMatches(expected));
}
