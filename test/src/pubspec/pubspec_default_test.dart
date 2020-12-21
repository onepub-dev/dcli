@t.Timeout(Duration(seconds: 600))
import 'package:dcli/dcli.dart';
import 'package:dcli/src/pubspec/pubspec.dart';
import 'package:dcli/src/pubspec/dependency.dart';
import 'package:dcli/src/script/script.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart' as t;

import '../util/test_file_system.dart';

void main() {
  const main = '''
void main()
{
  print ('hello world');
}
''';

  const basic = '''
name: test
version: 1.0.0
dependencies:
  collection: ^1.14.12
  file_utils: ^0.1.3
''';

  const overrides = '''
name: test
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
      final scriptDirectory = p.join(fs.fsRoot, 'local');
      final scriptPath = p.join(scriptDirectory, 'test.dart');
      final pubSpecScriptPath = p.join(scriptDirectory, 'pubspec.yaml');
      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      if (!exists(dirname(scriptPath))) {
        createDir(dirname(scriptPath));
      }
      final file = PubSpec.fromString(basic);
      file.saveToFile(pubSpecScriptPath);

      final dependencies = <Dependency>[];
      dependencies.add(Dependency.fromHosted('collection', '^1.14.12'));
      dependencies.add(Dependency.fromHosted('file_utils', '^0.1.3'));
      runTest(fs, null, main, dependencies);
    });
  }, skip: false);

  t.test('File - override', () {
    TestFileSystem().withinZone((fs) {
      final scriptDirectory = p.join(fs.fsRoot, 'local');
      final scriptPath = p.join(scriptDirectory, 'test.dart');
      final pubSpecScriptPath = p.join(scriptDirectory, 'pubspec.yaml');
      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      final file = PubSpec.fromString(overrides);
      file.saveToFile(scriptPath);

      final dependencies = <Dependency>[];
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
      final scriptDirectory = p.join(fs.fsRoot, 'local');
      final scriptPath = p.join(scriptDirectory, 'test.dart');
      final pubSpecScriptPath = p.join(scriptDirectory, 'pubspec.yaml');
      if (exists(pubSpecScriptPath)) {
        delete(pubSpecScriptPath);
      }
      final file = PubSpec.fromString(overrides);
      file.saveToFile(scriptPath);

      final dependencies = <Dependency>[];
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
  final scriptDirectory = p.join(fs.fsRoot, 'local');
  final scriptPath = p.join(scriptDirectory, 'test.dart');
  final script = Script.fromFile(scriptPath);

  // reset everything
  if (exists(scriptPath)) {
    delete(scriptPath);
  }

  if (exists(Settings().pathToDCli)) {
    deleteDir(Settings().pathToDCli);
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

  final pubspec = script.pubSpec;
  t.expect(pubspec.dependencies.values, t.unorderedMatches(expected));
}
