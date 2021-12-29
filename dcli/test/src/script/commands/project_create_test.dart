@Timeout(Duration(minutes: 5))
import 'package:dcli/dcli.dart' hide equals;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../util/test_file_system.dart';

void main() {
  const scriptName = 'simple.dart';

  group('Create Project', () {
    test('Create hello world', () {
      withTempDir((fs) {
        DartProject.create(pathTo: fs, templateName: 'simple').warmup();

        checkProjectStructure(fs, scriptName);
      });
    });

    test('Run hello world', () {
      TestFileSystem.common.withinZone((fs) {
        withTempDir((fs) {
          final pathToScript = truepath(fs, 'bin', scriptName);
          DartProject.create(pathTo: fs, templateName: 'simple').warmup();

          DartScript.fromFile(pathToScript).run();
        });
      });
    });

    test('With Lib', () {});
  });
}

void checkProjectStructure(String rootPath, String scriptName) {
  final scriptPath = join(rootPath, scriptName);
  expect(exists(scriptPath), equals(true));

  final pubspecPath = p.join(rootPath, 'pubspec.yaml');
  expect(exists(pubspecPath), equals(true));

  // There should be:
  // script
  // pubspec.lock
  // pubspec.yaml
  // .packages
  // .dart_tools
  // analysis_options.yaml

  final files = <String>[];
  find(
    '*.*',
    workingDirectory: rootPath,
    types: [Find.file],
    includeHidden: true,
  ).forEach(
    (line) => files.add(
      p.relative(line, from: rootPath),
    ),
  );

  // find('.*', recursive: false, root: fs.runtimePath(scriptName), types: [
  //   Find.file,
  // ]).forEach((line) => files.add(p.basename(line)));

  expect(
    files,
    unorderedEquals(<String>[
      scriptName,
      'pubspec.yaml',
      'pubspec.lock',
      'analysis_options.yaml',
      join('.dart_tool', 'package_config.json'),
      // ignore: lines_longer_than_80_chars
      '.packages' // when dart 2.10 is released this will no longer be created.
    ]),
  );

  final directories = <String>[];

  find(
    '*',
    recursive: false,
    workingDirectory: rootPath,
    types: [Find.directory],
    includeHidden: true,
  ).forEach((line) => directories.add(p.basename(line)));
  expect(directories, unorderedEquals(<String>['.dart_tool']));
}
