@Timeout(Duration(minutes: 10))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:dcli_sdk/src/commands/create.dart';
import 'package:dcli_sdk/src/script/verbose_flag.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

/// @Throwing(ArgumentError)
/// @Throwing(CreateDirException)
/// @Throwing(core.TouchException)
void main() {
  test('create no args', () async {
    await core.withTempDirAsync((dir) async {
      await capture(() async {
        /// no args
        await expectLater(
            () => CreateCommand().run([], []),
            throwsA(predicate((e) =>
                e is InvalidArgumentException &&
                e.message
                    .startsWith('The create command takes one argument'))));
      });
    });
  });
  test('create project', () async {
    await core.withTempDirAsync((dir) async {
      final pathToProject = join(dir, 'simple_project');

      await capture(() async {
        /// default simple project
        await CreateCommand().run([VerboseFlag()], [pathToProject]);
        expect(exists(pathToProject), isTrue);

        await expectLater(
            () => CreateCommand().run([], [pathToProject]),
            throwsA(predicate((e) =>
                e is InvalidArgumentException &&
                e.message.endsWith('already exists.'))));
      });
    });
  });
  test('create non-existant directory', () async {
    await core.withTempDirAsync((dir) async {
      final pathToSpawnScript = join(dir, 'bin/spawn.dart');

      await capture(() async {
        /// now args
        await expectLater(
            () => CreateCommand().run([], []),
            throwsA(predicate((e) =>
                e is InvalidArgumentException &&
                e.message
                    .startsWith('The create command takes one argument'))));

        ///
        await expectLater(
            () => CreateCommand().run([], [pathToSpawnScript]),
            throwsA(predicate((e) =>
                e is InvalidArgumentException &&
                e.message.startsWith('The script directory'))));

        await expectLater(
            () => CreateCommand().run([], [pathToSpawnScript]),
            throwsA(predicate((e) =>
                e is InvalidArgumentException &&
                e.message.endsWith('already exists.'))));

        createDir(dirname(pathToSpawnScript), recursive: true);
        touch(pathToSpawnScript, create: true);
        await expectLater(
            () => CreateCommand().run([], [pathToSpawnScript]),
            throwsA(predicate((e) =>
                e is InvalidArgumentException &&
                e.message.endsWith('already exists.'))));
      });
    });
  });
}
