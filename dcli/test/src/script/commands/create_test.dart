@Timeout(Duration(minutes: 10))
import 'package:dcli/dcli.dart';
import 'package:dcli/src/script/command_line_runner.dart';
import 'package:dcli/src/script/commands/create.dart';
import 'package:dcli/src/script/flags.dart';
import 'package:test/test.dart';

void main() {
  test('create no args', () async {
    withTempDir((dir) {
      /// no args
      expect(
          () => CreateCommand()..run([], []),
          throwsA(predicate((e) =>
              e is InvalidArgumentsException &&
              e.message.startsWith('The create command takes one argument'))));
    });
  });
  test('create project', () async {
    withTempDir((dir) {
      final pathToProject = join(dir, 'simple_project');

      /// default simple project
      CreateCommand().run([VerboseFlag()], [pathToProject]);
      expect(exists(pathToProject), isTrue);

      expect(
          () => CreateCommand()..run([], [pathToProject]),
          throwsA(predicate((e) =>
              e is InvalidArgumentsException &&
              e.message.endsWith('already exists.'))));
    });
  });
  test('create non-existant directory', () async {
    withTempDir((dir) {
      final pathToSpawnScript = join(dir, 'bin/spawn.dart');

      /// now args
      expect(
          () => CreateCommand()..run([], []),
          throwsA(predicate((e) =>
              e is InvalidArgumentsException &&
              e.message.startsWith('The create command takes one argument'))));

      ///
      expect(
          () => CreateCommand()..run([], [pathToSpawnScript]),
          throwsA(predicate((e) =>
              e is InvalidArgumentsException &&
              e.message.startsWith('The script directory'))));

      expect(
          () => CreateCommand()..run([], [pathToSpawnScript]),
          throwsA(predicate((e) =>
              e is InvalidArgumentsException &&
              e.message.endsWith('already exists.'))));

      createDir(dirname(pathToSpawnScript), recursive: true);
      touch(pathToSpawnScript, create: true);
      expect(
          () => CreateCommand()..run([], [pathToSpawnScript]),
          throwsA(predicate((e) =>
              e is InvalidArgumentsException &&
              e.message.endsWith('already exists.'))));
    });
  });
}
