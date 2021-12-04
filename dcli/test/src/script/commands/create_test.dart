@Timeout(Duration(minutes: 10))
import 'package:dcli/dcli.dart';
import 'package:dcli/src/script/command_line_runner.dart';
import 'package:dcli/src/script/commands/create.dart';
import 'package:test/test.dart';

void main() {
  test('create non-existant directory', () async {
    withTempDir((dir) {
      final pathToSpawnScript = join(dir, 'bin/spawn.dart');

      ///
      expect(
          () => CreateCommand()..run([], [pathToSpawnScript]),
          throwsA(predicate((e) =>
              e is InvalidArguments &&
              e.message.startsWith('The script directory'))));

      expect(
          () => CreateCommand()..run([], [pathToSpawnScript]),
          throwsA(predicate((e) =>
              e is InvalidArguments && e.message.endsWith('already exists.'))));

      createDir(dirname(pathToSpawnScript), recursive: true);
      touch(pathToSpawnScript, create: true);
      expect(
          () => CreateCommand()..run([], [pathToSpawnScript]),
          throwsA(predicate((e) =>
              e is InvalidArguments && e.message.endsWith('already exists.'))));
    });
  });
}
