@t.Timeout(Duration(seconds: 600))
import 'package:dcli/dcli.dart';
import 'package:dcli/src/pubspec/pubspec.dart';
import 'package:dcli/src/script/dependency.dart';
import 'package:dcli/src/script/script.dart';
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
  dcli: ^2.0.0
  args: ^2.0.1
  collection: ^1.14.12
  file_utils: ^0.1.3
  path: ^2.0.2
''';

  t.test('File - basic', () {
    TestFileSystem().withinZone((fs) {
      var scriptDirectory = p.join(fs.fsRoot, 'local');
      var scriptPath = p.join(scriptDirectory, 'test.dart');
      var pubSpecScriptPath = p.join(scriptDirectory, 'pubspec.yaml');
      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      if (!exists(dirname(scriptPath))) {
        createDir(dirname(scriptPath));
      }
      var file = PubSpec.fromString(basic);
      file.saveToFile(pubSpecScriptPath);

      var dependencies = <Dependency>[];
      dependencies.add(Dependency.fromHosted('collection', '^1.14.12'));
      dependencies.add(Dependency.fromHosted('file_utils', '^0.1.3'));
      runTest(fs, null, main, dependencies);
    });
  }, skip: false);

  t.test('File - override', () {
    TestFileSystem().withinZone((fs) {
      var scriptDirectory = p.join(fs.fsRoot, 'local');
      var scriptPath = p.join(scriptDirectory, 'test.dart');
      var pubSpecScriptPath = p.join(scriptDirectory, 'pubspec.yaml');
      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      var file = PubSpec.fromString(overrides);
      file.saveToFile(scriptPath);

      var dependencies = <Dependency>[];
      dependencies.add(Dependency.fromHosted('dcli', '^2.0.0'));
      dependencies.add(Dependency.fromHosted('args', '^2.0.1'));
      dependencies.add(Dependency.fromHosted('path', '^2.0.2'));
      dependencies.add(Dependency.fromHosted('collection', '^1.14.12'));
      dependencies.add(Dependency.fromHosted('file_utils', '^0.1.3'));
      runTest(fs, null, main, dependencies);
    });
  }, skip: false);

  t.test('File - local pubsec.yaml', () {
    TestFileSystem().withinZone((fs) {
      var scriptDirectory = p.join(fs.fsRoot, 'local');
      var scriptPath = p.join(scriptDirectory, 'test.dart');
      var pubSpecScriptPath = p.join(scriptDirectory, 'pubspec.yaml');
      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      var file = PubSpec.fromString(overrides);
      file.saveToFile(scriptPath);

      var dependencies = <Dependency>[];
      dependencies.add(Dependency.fromHosted('dcli', '^2.0.0'));
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
  var scriptDirectory = p.join(fs.fsRoot, 'local');
  var scriptPath = p.join(scriptDirectory, 'test.dart');
  var script = Script.fromFile(scriptPath);

  // reset everything
  if (exists(scriptPath)) {
    delete(scriptPath);
  }

  if (exists(Settings().pathToDCli)) {
    deleteDir(Settings().pathToDCli, recursive: true);
  }

  if (!exists(Settings().pathToDCli)) {
    createDir(Settings().pathToDCli);
  }

  if (!exists(scriptDirectory)) {
    createDir(scriptDirectory, recursive: true);
  }
  if (annotation != null) {
    scriptPath.append(annotation);
  }
  scriptPath.append(main);

  var pubspec = script.pubSpec;
  t.expect(pubspec.dependencies.values, t.unorderedMatches(expected));
}
