@Timeout(Duration(minutes: 5))
import 'package:dcli/dcli.dart' hide equals;
import 'package:dcli/src/script/commands/install.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../util/test_file_system.dart';
import '../../util/test_scope.dart';

void main() {
  const scriptName = 'test.dart';

  group('Create Project', () {
    test('Create hello world', () {
      withTestScope((fs) {
        _installTemplates();
        final pathToTemplate = join(fs, 'test');
        DartProject.create(pathTo: pathToTemplate, templateName: 'simple')
            .warmup();

        checkProjectStructure(pathToTemplate, scriptName);
      });
    });

    test('Run hello world', () {
      TestFileSystem.common.withinZone((fs) {
        withTempDir((fs) {
          _installTemplates();
          final pathToScript = truepath(fs, 'test', 'bin', scriptName);
          final pathToTemplate = join(fs, 'test');
          DartProject.create(pathTo: pathToTemplate, templateName: 'simple')
              .warmup();

          DartScript.fromFile(pathToScript).run();
        });
      });
    });

    test('With Lib', () {});
  });
}

void _installTemplates() {
  InstallCommand().initTemplates();
}

void checkProjectStructure(String rootPath, String scriptName) {
  final scriptPath = join(rootPath, 'bin', scriptName);
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
      // ignore: lines_longer_than_80_chars
      '.packages', // when dart 2.10 is released this will no longer be created.
      'README.md',
      'pubspec.yaml',
      'analysis_options.yaml',
      'CHANGELOG.md',
      'pubspec.lock',
      join('.dart_tool', 'package_config.json'),
      join('bin', scriptName),
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
  expect(directories, unorderedEquals(<String>['.dart_tool', 'bin']));
}
