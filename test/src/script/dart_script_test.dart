import 'package:dcli/dcli.dart' hide equals;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('dart script ...', () async {
    expect(
      DartScript.stripDartVersionSuffix('pub_release.dart-2.13.0'),
      equals('pub_release.dart'),
    );

    expect(
      DartScript.stripDartVersionSuffix('pub_release.dart'),
      equals('pub_release.dart'),
    );

    expect(
      DartScript.stripDartVersionSuffix(
        p.join('some', 'path', 'pub_release.dart-2.13.0'),
      ),
      equals(p.join('some', 'path', 'pub_release.dart')),
    );

    expect(
      DartScript.stripDartVersionSuffix(
        p.join('some', 'path', 'pub_release.dart'),
      ),
      equals(p.join('some', 'path', 'pub_release.dart')),
    );

    expect(
      DartScript.fromFile('dart_script_test.dart').scriptName,
      equals('dart_script_test.dart'),
    );
  });

  group('pathToScript', () {
    const packageName = 'dcli_unit_tester';
    final pathToTestScript = truepath(p.join(
        'test', 'test_script', packageName, 'bin', 'dcli_unit_tester.dart'));

    test('within unit test', () {
      // within a unit test
      expect(DartScript.self.pathToScript, pathToTestScript);
    });

    test('jit script', () {
      chmod(740, pathToTestScript);
      final result = 'dart $pathToTestScript'
          .start(progress: Progress.capture(), nothrow: true)
          .toList();
      expect(result.length, equals(1));
      expect(result[0], equals(pathToTestScript));
    });

    test('compiled script', () {
      DartScript.fromFile(pathToTestScript)
          .compile(workingDirectory: dirname(pathToTestScript));

      final pathToCompiledScript = join(dirname(pathToTestScript),
          basenameWithoutExtension(pathToTestScript));

      expect(exists(pathToCompiledScript), isTrue);

      // run compiled script
      final result =
          pathToCompiledScript.start(progress: Progress.capture()).toList();

      expect(result.length, equals(1));
      expect(result[0], equals(pathToCompiledScript));
    });

    test('globally activated script', () {
      DartSdk().globalActivate(packageName);

      final result = packageName.start(progress: Progress.capture()).toList();

      expect(result.length, equals(1));
      expect(result[0], equals(join(PubCache().pathToBin, packageName)));
    });
  });
}
