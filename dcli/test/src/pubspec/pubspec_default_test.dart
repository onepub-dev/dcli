@t.Timeout(Duration(seconds: 600))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
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

  t.test(
    'File - basic',
    () async {
      await TestFileSystem().withinZone((fs) async {
        final pubSpecScriptPath = createPubspecPath(fs);
        PubSpec.fromString(basic).save(pubSpecScriptPath);

        final dependencies = <Dependency>[
          Dependency.fromHosted('collection', '^1.14.12'),
          Dependency.fromHosted('file_utils', '^0.1.3')
        ];
        runTest(fs, null, main, dependencies);
      });
    },
    skip: false,
  );

  t.test(
    'File - override',
    () async {
      await TestFileSystem().withinZone((fs) async {
        final scriptPath = createScriptPath(fs);

        PubSpec.fromString(overrides).save(scriptPath);

        final dependencies = <Dependency>[
          Dependency.fromHosted('dcli', '^2.0.0'),
          Dependency.fromHosted('args', '^2.0.1'),
          Dependency.fromHosted('path', '^2.0.2'),
          Dependency.fromHosted('collection', '^1.14.12'),
          Dependency.fromHosted('file_utils', '^0.1.3')
        ];
        runTest(fs, null, main, dependencies);
      });
    },
    skip: false,
  );

  t.test(
    'File - local pubsec.yaml',
    () async {
      await TestFileSystem().withinZone((fs) async {
        final scriptPath = createScriptPath(fs);
        PubSpec.fromString(overrides).save(scriptPath);

        final dependencies = <Dependency>[
          Dependency.fromHosted('dcli', '^2.0.0'),
          Dependency.fromHosted('args', '^2.0.1'),
          Dependency.fromHosted('path', '^2.0.2'),
          Dependency.fromHosted('collection', '^1.14.12'),
          Dependency.fromHosted('file_utils', '^0.1.3')
        ];
        runTest(fs, null, main, dependencies);
      });
    },
    skip: false,
  );
}

String createPubspecPath(TestFileSystem fs) {
  final scriptDirectory = p.join(fs.fsRoot, 'local');

  if (!exists(scriptDirectory)) {
    createDir(scriptDirectory, recursive: true);
  }

  final pubSpecScriptPath = p.join(scriptDirectory, 'pubspec.yaml');

  if (exists(pubSpecScriptPath)) {
    delete(pubSpecScriptPath);
  }

  return pubSpecScriptPath;
}

String createScriptPath(TestFileSystem fs) {
  final scriptDirectory = p.join(fs.fsRoot, 'local');

  if (!exists(scriptDirectory)) {
    createDir(scriptDirectory, recursive: true);
  }
  final scriptPath = p.join(scriptDirectory, 'test.dart');

  if (!exists(dirname(scriptPath))) {
    createDir(dirname(scriptPath));
  }
  return scriptPath;
}

void runTest(
  TestFileSystem fs,
  String? annotation,
  String main,
  List<Dependency> expected,
) {
  final scriptPath = createScriptPath(fs);
  final script = DartScript.fromFile(scriptPath);

  if (exists(Settings().pathToDCli)) {
    deleteDir(Settings().pathToDCli);
  }

  if (!exists(Settings().pathToDCli)) {
    createDir(Settings().pathToDCli);
  }

  if (annotation != null) {
    scriptPath.append(annotation);
  }
  scriptPath.append(main);

  final pubspec = script.pubSpec;
  t.expect(pubspec.dependencies.values, t.unorderedMatches(expected));
}
