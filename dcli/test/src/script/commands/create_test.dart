@Timeout(Duration(minutes: 10))
/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli/src/commands/create.dart';
import 'package:dcli/src/script/command_line_runner.dart';
import 'package:dcli/src/script/flags.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('create no args', () async {
    await core.withTempDir((dir) async {
      await capture(() async {
        /// no args
        expect(
            () => CreateCommand()..run([], []),
            throwsA(predicate((e) =>
                e is InvalidArgumentException &&
                e.message
                    .startsWith('The create command takes one argument'))));
      });
    });
  });
  test('create project', () async {
    await core.withTempDir((dir) async {
      final pathToProject = join(dir, 'simple_project');

      await capture(() async {
        /// default simple project
        CreateCommand().run([VerboseFlag()], [pathToProject]);
        expect(exists(pathToProject), isTrue);

        expect(
            () => CreateCommand()..run([], [pathToProject]),
            throwsA(predicate((e) =>
                e is InvalidArgumentException &&
                e.message.endsWith('already exists.'))));
      });
    });
  });
  test('create non-existant directory', () async {
    await core.withTempDir((dir) async {
      final pathToSpawnScript = join(dir, 'bin/spawn.dart');

      await capture(() async {
        /// now args
        expect(
            () => CreateCommand()..run([], []),
            throwsA(predicate((e) =>
                e is InvalidArgumentException &&
                e.message
                    .startsWith('The create command takes one argument'))));

        ///
        expect(
            () => CreateCommand()..run([], [pathToSpawnScript]),
            throwsA(predicate((e) =>
                e is InvalidArgumentException &&
                e.message.startsWith('The script directory'))));

        expect(
            () => CreateCommand()..run([], [pathToSpawnScript]),
            throwsA(predicate((e) =>
                e is InvalidArgumentException &&
                e.message.endsWith('already exists.'))));

        createDir(dirname(pathToSpawnScript), recursive: true);
        touch(pathToSpawnScript, create: true);
        expect(
            () => CreateCommand()..run([], [pathToSpawnScript]),
            throwsA(predicate((e) =>
                e is InvalidArgumentException &&
                e.message.endsWith('already exists.'))));
      });
    });
  });
}
