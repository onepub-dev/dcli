@t.Timeout(Duration(seconds: 600))
import 'package:dshell/dshell.dart';
import 'package:dshell/src/pubspec/global_dependancies.dart';
import 'package:dshell/src/pubspec/pubspec.dart';
import 'package:dshell/src/script/dependency.dart';
import 'package:dshell/src/script/project_cache.dart';
import 'package:dshell/src/script/script.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart' as t;

import '../test_settings.dart';
import '../util/test_fs_zone.dart';

String scriptDirectory = p.join(TEST_ROOT, 'local');
String scriptPath = p.join(scriptDirectory, 'test.dart');
String pubSpecScriptPath = p.join(scriptDirectory, 'pubspec.yaml');

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

  t.test('No PubSpec - No Dependancies', () {
    TestZone().run(() {
      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      runTest(null, main, GlobalDependancies.defaultDependencies);
    });
  }, skip: false);

  var annotationNoOverrides = '''
    /* @pubspec
${basic}
*/
  ''';

  t.test('Annotation - No Overrides', () {
    TestZone().run(() {
      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      var dependencies = GlobalDependancies.defaultDependencies;
      dependencies.add(Dependency('collection', '^1.14.12'));
      dependencies.add(Dependency('file_utils', '^0.1.3'));
      runTest(annotationNoOverrides, main, dependencies);
    });
  }, skip: false);

  var annotationWithOverrides = '''
    /* @pubspec
$overrides
*/
  ''';

  t.test('Annotaion With Overrides', () {
    TestZone().run(() {
      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      var dependencies = <Dependency>[];
      dependencies.add(Dependency('dshell', '^2.0.0'));
      dependencies.add(Dependency('args', '^2.0.1'));
      dependencies.add(Dependency('path', '^2.0.2'));
      dependencies.add(Dependency('collection', '^1.14.12'));
      dependencies.add(Dependency('file_utils', '^0.1.3'));
      runTest(annotationWithOverrides, main, dependencies);
    });
  }, skip: false);

  t.test('File - basic', () {
    TestZone().run(() {
      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      PubSpec file = PubSpecImpl.fromString(basic);
      file.writeToFile(scriptPath);

      var dependencies = GlobalDependancies.defaultDependencies;
      dependencies.add(Dependency('collection', '^1.14.12'));
      dependencies.add(Dependency('file_utils', '^0.1.3'));
      runTest(null, main, dependencies);
    });
  }, skip: false);

  t.test('File - override', () {
    TestZone().run(() {
      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      PubSpec file = PubSpecImpl.fromString(overrides);
      file.writeToFile(scriptPath);

      var dependencies = <Dependency>[];
      dependencies.add(Dependency('dshell', '^2.0.0'));
      dependencies.add(Dependency('args', '^2.0.1'));
      dependencies.add(Dependency('path', '^2.0.2'));
      dependencies.add(Dependency('collection', '^1.14.12'));
      dependencies.add(Dependency('file_utils', '^0.1.3'));
      runTest(null, main, dependencies);
    });
  }, skip: false);
}

void runTest(String annotation, String main, List<Dependency> expected) {
  var script = Script.fromFile(scriptPath);

  // reset everything
  if (exists(scriptPath)) {
    delete(scriptPath);
  }

  if (exists(Settings().dshellPath)) {
    deleteDir(Settings().dshellPath, recursive: true);
  }

  createDir(Settings().dshellPath);
  GlobalDependancies.createDefault();

  ProjectCache().initCache();

  createDir(scriptDirectory, recursive: true);
  if (annotation != null) {
    scriptPath.append(annotation);
  }
  scriptPath.append(main);

  var project =
      ProjectCache().createProject(script, skipPubGet: true);

  var pubspec = project.pubSpec();
  t.expect(pubspec.dependencies, t.unorderedMatches(expected));
}
