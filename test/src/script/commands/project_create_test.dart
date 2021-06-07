@Timeout(Duration(minutes: 5))
import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

import 'package:path/path.dart' as p;

void main() {
  const scriptName = 'create_test.dart';

  group('Create Project', () {
    test('Create hello world', () {
      withTempDir((fs) {
        final pathToScript = truepath(fs, scriptName);

        DartProject.fromPath(fs, search: false)
          ..createScript(scriptName, templateName: 'hello_world.dart')
          ..warmup();

        checkProjectStructure(fs, pathToScript);
      });
    });

    test('Run hello world', () {
      withTempDir((fs) {
        final pathToScript = truepath(fs, 'hello_world.dart');
        DartScript.fromFile(pathToScript).run();
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
      p.relative(line, from: join(rootPath, scriptName)),
    ),
  );

  // find('.*', recursive: false, root: fs.runtimePath(scriptName), types: [
  //   Find.file,
  // ]).forEach((line) => files.add(p.basename(line)));

  expect(
      files,
      unorderedEquals(<String>[
        'hello_world.dart',
        'pubspec.yaml',
        'pubspec.lock',
        'analysis_options.yaml',
        join('.dart_tool', 'package_config.json'),
        // ignore: lines_longer_than_80_chars
        '.packages' // when dart 2.10 is released this will no longer be created.
      ]));

  final directories = <String>[];

  find('*',
          recursive: false,
          workingDirectory: join(rootPath, scriptName),
          types: [Find.directory],
          includeHidden: true)
      .forEach((line) => directories.add(p.basename(line)));
  expect(directories, unorderedEquals(<String>['.dart_tool']));
}
