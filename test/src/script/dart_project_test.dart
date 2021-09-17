import 'package:dcli/dcli.dart' hide equals;
import 'package:test/test.dart';

void main() {
  test('dart project directories', () async {
    expect(DartProject.fromPath(pwd).pathToProjectRoot, equals(truepath('.')));
    expect(
      DartProject.fromPath(pwd).pathToPubSpec,
      equals(truepath('pubspec.yaml')),
    );
    expect(
      DartProject.fromPath(pwd).pathToDartToolDir,
      equals(truepath('.dart_tool')),
    );
    expect(DartProject.fromPath(pwd).pathToToolDir, equals(truepath('tool')));
    expect(DartProject.fromPath(pwd).pathToBinDir, equals(truepath('bin')));
    expect(DartProject.fromPath(pwd).pathToTestDir, equals(truepath('test')));
  });
}
