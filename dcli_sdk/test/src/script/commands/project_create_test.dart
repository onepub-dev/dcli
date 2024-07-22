@Timeout(Duration(minutes: 5))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_sdk/src/templates.dart';
import 'package:dcli_test/dcli_test.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() {
  const scriptName = 'test.dart';

  group('Create Project', () {
    test('Create hello world', () async {
      await withTestScope((fs) async {
        await capture(() async {
          _installTemplates();
          final pathToTemplate = join(fs, 'test');

          await core.withEnvironmentAsync(() async {
            await DartProject.create(
                    pathTo: pathToTemplate, templateName: 'simple')
                .warmup();
          }, environment: {
            'DCLI_OVERRIDE_PATH': DartProject.self.pathToProjectRoot
          });

          checkProjectStructure(pathToTemplate, scriptName);
        });
      });
    });

    test('Run hello world', () async {
      await capture(() async {
        await TestFileSystem.common.withinZone((fs) async {
          await withTempDir((fs) async {
            _installTemplates();
            final pathToScript = truepath(fs, 'test', 'bin', scriptName);
            final pathToTemplate = join(fs, 'test');

            await core.withEnvironmentAsync(() async {
              await DartProject.create(
                      pathTo: pathToTemplate, templateName: 'simple')
                  .warmup();
            }, environment: {
              'DCLI_OVERRIDE_PATH': DartProject.self.pathToProjectRoot
            });

            final progress = DartScript.fromFile(pathToScript).start();
            expect(progress.exitCode == 0, isTrue);
            expect(exists(pathToScript), isTrue);
          });
        });
      });
    });

    test('With Lib', () {});
  });
}

void _installTemplates() {
  initTemplates(print);
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
